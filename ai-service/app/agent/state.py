from typing import Optional, List
from pydantic import BaseModel, Field


class ClinicalHistory(BaseModel):
    chief_complaint: Optional[str] = None

    onset: Optional[str] = None
    duration: Optional[str] = None
    location: Optional[str] = None
    character: Optional[str] = None
    radiation: Optional[str] = None
    severity: Optional[str] = None
    aggravating_factors: Optional[str] = None
    relieving_factors: Optional[str] = None

    associated_symptoms: List[str] = Field(default_factory=list)

    past_medical_history: List[str] = Field(default_factory=list)
    surgical_history: List[str] = Field(default_factory=list)

    medications: List[str] = Field(default_factory=list)
    allergies: List[str] = Field(default_factory=list)

    family_history: List[str] = Field(default_factory=list)
    personal_history: List[str] = Field(default_factory=list)

    review_of_systems: List[str] = Field(default_factory=list)


class ClinicalState(BaseModel):
    patient_id: Optional[str] = None
    language: str = "English"

    history: ClinicalHistory = Field(
        default_factory=ClinicalHistory
    )

    current_section: str = "chief_complaint"

    red_flags: List[str] = Field(default_factory=list)

    priority: str = "NORMAL"

    completed: bool = False