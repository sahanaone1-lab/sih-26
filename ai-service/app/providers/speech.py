import os
import httpx
from fastapi import UploadFile, HTTPException

class SarvamSpeechProvider:
    def __init__(self):
        self.api_key = os.getenv("SARVAM_API_KEY", "")
        self.url = "https://api.sarvam.ai/speech-to-text"

    async def transcribe(self, file: UploadFile, language_code: str = "Unknown") -> str:
        """
        Transcribes the audio using Sarvam Saaras API.
        language_code can be 'ta-IN', 'en-IN', 'hi-IN', or 'Unknown' for automatic language detection / mixed language.
        """
        if not self.api_key:
            # If no API key is provided, return a simulated response for testing
            return "Simulated Tanglish transcription: I have fever for 2 days."

        headers = {
            "api-subscription-key": self.api_key
        }

        # Need to read the file contents
        file_content = await file.read()

        # Prepare the multipart form data
        files = {
            "file": (file.filename, file_content, file.content_type or "audio/wav")
        }
        data = {
            "language_code": language_code,
            "model": "saaras:v3"
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            try:
                response = await client.post(
                    self.url,
                    headers=headers,
                    files=files,
                    data=data
                )
                response.raise_for_status()
                result = response.json()
                
                # Usually Sarvam returns {"transcript": "..."}
                return result.get("transcript", "")
            except httpx.HTTPStatusError as e:
                raise HTTPException(status_code=e.response.status_code, detail=f"Sarvam API Error: {e.response.text}")
            except Exception as e:
                raise HTTPException(status_code=500, detail=str(e))
