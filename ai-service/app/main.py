import os

from fastapi import FastAPI, UploadFile, File, Form
from pydantic import BaseModel
from dotenv import load_dotenv

from app.agent.medi_kiosk_agent import MediKioskAgent
from app.agent.state import ClinicalState
from app.providers.speech import SarvamSpeechProvider


load_dotenv()

app = FastAPI(
    title="MediKiosk AI Service",
    version="0.1.0",
)

agent = MediKioskAgent(
    ollama_url=os.getenv(
        "OLLAMA_URL",
        "http://localhost:11434",
    ),
    model=os.getenv(
        "OLLAMA_MODEL",
        "qwen3:8b",
    ),
)

speech_provider = SarvamSpeechProvider()


class ChatRequest(BaseModel):
    message: str
    state: ClinicalState = ClinicalState()


@app.get("/health")
async def health():
    return {
        "status": "ok",
        "service": "medikiosk-ai",
        "model": os.getenv("OLLAMA_MODEL"),
    }


@app.post("/agent/chat")
async def agent_chat(request: ChatRequest):

    result = await agent.process(
        user_message=request.message,
        state=request.state,
    )

    return result

@app.post("/api/ai/speech-to-text")
async def speech_to_text(
    file: UploadFile = File(...),
    language_code: str = Form("Unknown")
):
    transcript = await speech_provider.transcribe(file, language_code)
    return {"transcript": transcript}