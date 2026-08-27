from app.agent.state import ClinicalState


def evaluate_triage(state: ClinicalState) -> ClinicalState:
    history = state.history

    flags = []

    if history.chief_complaint:
        complaint = history.chief_complaint.lower()

        if "chest pain" in complaint:
            flags.append("chest_pain")

    if history.radiation:
        radiation = history.radiation.lower()

        if "left arm" in radiation or "left hand" in radiation:
            flags.append("radiation_left_arm")

    for symptom in history.associated_symptoms:
        symptom_lower = symptom.lower()

        if "breathlessness" in symptom_lower or "shortness of breath" in symptom_lower or "difficulty breathing" in symptom_lower:
            flags.append("breathlessness")

        if "fainting" in symptom_lower or "syncope" in symptom_lower or "passed out" in symptom_lower:
            flags.append("syncope")
            
        if "vomiting blood" in symptom_lower:
            flags.append("hematemesis")
            
        if "sudden weakness" in symptom_lower or "slurred speech" in symptom_lower:
            flags.append("stroke_symptoms")

    state.red_flags = list(set(flags))

    critical_flags = {
        "chest_pain",
        "radiation_left_arm",
        "breathlessness",
        "syncope",
        "hematemesis",
        "stroke_symptoms"
    }

    if len(critical_flags.intersection(state.red_flags)) >= 1:
        state.priority = "EMERGENCY"

    return state