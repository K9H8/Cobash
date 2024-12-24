import speech_recognition as sr
import os
import sys 
# Suppress ALSA lib warnings
os.environ["PYTHONWARNINGS"] = "ignore"
os.environ["SDL_AUDIODRIVER"] = "dummy"  # Optional: Disables some sound backends
os.environ["ALSA_DEBUG"] = "0"
sys.stderr = open(os.devnull, 'w')

def mic_to_text_auto_stop():
    recognizer = sr.Recognizer()
    mic = sr.Microphone()
    with mic as source:  # Use the mic context manager once
        recognizer.adjust_for_ambient_noise(source)
        recognizer.pause_threshold = 2

        try:
            print("Listening...")
            # Listen for the audio (auto-stops after 3 seconds of silence)
            audio = recognizer.listen(source, timeout=15)

            print("Recognizing speech...\n")
            text = recognizer.recognize_google(audio)
            print(text,"\n")
            return text        
        except sr.WaitTimeoutError:
            print("No speech detected within the timeout period.")
        except sr.UnknownValueError:
            print("Speech was unintelligible.")
        except sr.RequestError as e:
            print(f"Could not request results from Google Speech Recognition service; {e}")

if __name__ == "__main__":
    mic_to_text_auto_stop()
