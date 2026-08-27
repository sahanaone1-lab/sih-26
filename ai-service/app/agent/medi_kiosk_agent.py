import json
import httpx

from app.agent.state import ClinicalState
from app.clinical.triage import evaluate_triage


class MediKioskAgent:

    def __init__(
        self,
        ollama_url: str,
        model: str,
    ):
        self.ollama_url = ollama_url
        self.model = model

    async def ask_model(self, messages):

        payload = {
            "model": self.model,
            "messages": messages,
            "stream": False,
            "format": "json",
        }

        async with httpx.AsyncClient(timeout=120) as client:
            response = await client.post(
                f"{self.ollama_url}/api/chat",
                json=payload,
            )

        response.raise_for_status()

        data = response.json()

        return data["message"]["content"]

    async def process(
        self,
        user_message: str,
        state: ClinicalState,
    ):

        system_prompt = """
You are MediKiosk AI, a clinical history-taking assistant.

Your job is to help collect structured medical history.

You are NOT a doctor.
You must NOT diagnose disease.
You must NOT prescribe medication.

Your responsibilities:
1. Understand what the patient says.
2. Extract clinically relevant information.
3. Ask the next appropriate history question.
4. Avoid repeating information already collected.
5. Use simple language.
6. Respect the patient's selected language.
7. Follow the clinical history structure.
8. If the current priority is "EMERGENCY", you MUST immediately tell the patient to seek urgent medical attention and halt further questioning.

You MUST respond strictly in JSON format. Do not include markdown formatting or backticks around the JSON. Your response must have the following structure:
{
    "reply": "Your message to the patient",
    "state": {
        "current_section": "chief_complaint",
        "history": {
            "chief_complaint": "Extracted string or null",
            "onset": "Extracted string or null",
            "duration": "Extracted string or null",
            "associated_symptoms": ["list", "of", "strings"]
        }
    }
}
Note: Make sure to preserve any existing history data in the state when you update it! Only change state fields when new information is provided by the patient.

Current clinical state:
""" + state.model_dump_json()

        messages = [
            {
                "role": "system",
                "content": system_prompt,
            },
            {
                "role": "user",
                "content": user_message,
            },
        ]

        answer_text = await self.ask_model(messages)
        
        try:
            parsed_answer = json.loads(answer_text)
            reply_text = parsed_answer.get("reply", "I'm sorry, I didn't catch that.")
            updated_state_dict = parsed_answer.get("state", state.model_dump())
            
            # Reconstruct the state object
            # Merge with existing state to avoid dropping fields not emitted by LLM
            current_state_dict = state.model_dump()
            
            # Deep merge history
            if "history" in updated_state_dict:
                for k, v in updated_state_dict["history"].items():
                    if v: # Only update if a value is provided
                        current_state_dict["history"][k] = v
            
            if "current_section" in updated_state_dict:
                current_state_dict["current_section"] = updated_state_dict["current_section"]
                
            new_state = ClinicalState(**current_state_dict)
            
        except json.JSONDecodeError:
            reply_text = "I encountered an error understanding your request. Could you please rephrase?"
            new_state = state

        new_state = evaluate_triage(new_state)

        return {
            "response": reply_text,
            "state": new_state.model_dump(),
        }