import pprint
import requests
from time import sleep

# passes the audio file to the upload endpoint
def read_file(filename):
    with open(filename, 'rb') as _file:
        while True:
            data = _file.read()
            if not data:
                break
            yield data

# takes in speech and outputs text (speech to text)
def get_speech_info(filename):
    auth_key = "53477ee00b3649d1a509489f0ddafe6f"#///AssemblyAI key goes in this///
    headers = {
        "authorization": auth_key,
        "content-type": "application/json"
    }

    transcript_endpoint = "https://api.assemblyai.com/v2/transcript"
    upload_endpoint = "https://api.assemblyai.com/v2/upload"

    # for uploading the audio file
    upload_response = requests.post(
        upload_endpoint,
        headers=headers, data=read_file(filename)
    )
    print("Audio file uploaded")

    transcript_request = {"audio_url": upload_response.json()["upload_url"], "sentiment_analysis": True}
    transcript_response = requests.post(transcript_endpoint, headers=headers, json=transcript_request)
    print("Transcription requested")
    pprint.pprint(transcript_response.json())

    polling_response = requests.get(transcript_endpoint + "/" + transcript_response.json()['id'], headers=headers)

    while polling_response.json()['status'] != 'completed':
        sleep(20)
        polling_response = requests.get(transcript_endpoint + "/" + transcript_response.json()['id'], headers=headers)
        print("File is", polling_response.json()['status'])

    return polling_response.json()

