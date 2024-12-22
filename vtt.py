import speech_recognition as sr

def mic_to_text():
    recognizer = sr.Recognizer()
    mic = sr.Microphone()
    
    print("Adjusting for ambient noise... Please wait.")
    with mic as source:
        recognizer.adjust_for_ambient_noise(source)
        print(f"Adjusted. Ambient noise threshold: {recognizer.energy_threshold}")
        print("You can now speak...")
        
        try:
            audio = recognizer.listen(source, timeout=10)  # Listen for 10 seconds
            print("Recognizing speech...")
            text = recognizer.recognize_google(audio)
            print(f"You said: {text}")
        except sr.WaitTimeoutError:
            print("No speech detected within the timeout period.")
        except sr.UnknownValueError:
            print("Speech was unintelligible.")
        except sr.RequestError as e:
            print(f"Could not request results from Google Speech Recognition service; {e}")

if __name__ == "__main__":
    mic_to_text()
