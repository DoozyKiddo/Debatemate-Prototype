import spacy
from parselmouth.praat import run_file

# original duration stands for the duration of the entire audio file
# speaking duration stands for the duration of the speaker speaking

# returning information from the praat code
# m is the filename, and p is the name of the folder
def run_praat_file(m, p):
    praat_path = p + "/dataset/essen/myspsolution.praat"
    sound = "audioFiles/" + m + ".wav"
    path = "audioFiles/"

    try:
        objects = run_file(praat_path, -20, 2, 0.3, "yes", sound, path, 80, 400, 0.01, capture_output=True)
        strObjects = str(objects[1])
        file_data = strObjects.strip().split()
        return file_data
    except Exception as e:
        print("The audio was not able to be computed, please try a different audio file")
        print(e)

# returns number of pauses in the speech
def mysppause(m, p):
    file_data = run_praat_file(m, p)
    num_pauses = int(file_data[1])
    print("Number of pauses =", num_pauses)
    return num_pauses

# returns rate of number of syllables spoken per second with the original duration
def myspspeechrate(m, p):
    file_data = run_praat_file(m, p)
    rate_of_speech = int(file_data[2])
    print("Rate of speech =", rate_of_speech, "syllables per second (including pauses)")
    return rate_of_speech

# returns rate of number of syllables spoken per second with the speaking duration
def mysparticulation(m, p):
    file_data = run_praat_file(m, p)
    articulation_rate = int(file_data[3])
    print("Articulation rate =", articulation_rate, "syllables per second (speaking only)")
    return articulation_rate

# returns number of seconds without pauses
def myspspeakingduration(m, p):
    file_data = run_praat_file(m, p)
    speaking_duration = int(file_data[4])
    print("Speaking duration =", speaking_duration, "seconds without pauses")
    return speaking_duration

# returns number of seconds with pauses
def mysporiginalduration(m, p):
    file_data = run_praat_file(m, p)
    original_duration = int(file_data[5])
    print("Original duration =", original_duration, "seconds with pauses")
    return original_duration

# returns ratio between speaking duration and original duration, (speaking duration)/(original duration)
def myspbalance(m, p):
    file_data = run_praat_file(m, p)
    balance = float(file_data[6])
    print("balance =", balance)
    return balance

# returns overview of all the audio data
def mysptotal(m, p):
  file_data = run_praat_file(m, p)

  vocal_range_average = float(file_data[7])
  gender = ""
  if 97 < vocal_range_average <= 163:
    gender = "Male"
  elif 163 < vocal_range_average <= 245:
    gender = "Female"
  else:
    gender = "Voice was not recognized"
  
  fmin = float(file_data[12])
  fmax = float(file_data[13])
  frange = fmax - fmin
  mood = ""
  if frange < 2:
    mood = "Showing no emotion"
  elif frange < 6:
    mood = "Showing very little emotion"
  elif frange < 10:
    mood = "Showing little emotion"
  elif frange < 14:
    mood = "Showing some emotion"
  elif frange < 20:
    mood = "Speaking slightly passionately"
  elif frange < 30:
    mood = "Speaking passionately"
  elif frange < 40:
    mood = "Speaking very passionately"
  else:
    mood = "Speaking extremely passionately"
    file_data.append(gender)
    file_data.append(mood)
    print(file_data)
    data = {"number_of_syllables": file_data[0], "number_of_pauses": file_data[1], "rate_of_speech": file_data[2],
            "articulation_rate": file_data[3], "speaking_duration": file_data[4], "original_duration": file_data[5],
            "balance": file_data[6], "f0_mean": file_data[7], "f0_std": file_data[8], "f0_median": file_data[9],
            "f0_min": file_data[10], "f0_max": file_data[11], "f0_quantile25": file_data[12], "f0_quantile75": file_data[13], "gender": file_data[15], "mood": file_data[16]}
    return data

def myspmood(m, p):
  file_data = run_praat_file(m, p)
  fmin = float(file_data[12])
  fmax = float(file_data[13])
  frange = fmax - fmin
  if frange < 1:
    return "Showing no emotion"
  elif frange < 3:
    return "Showing very little emotion"
  elif frange < 5:
    return "Showing little emotion"
  elif frange < 7:
    return "Showing some emotion"
  elif frange < 10:
    return "Speaking slightly passionately"
  elif frange < 15:
    return "Speaking passionately"
  elif frange < 20:
    return "Speaking very passionately"
  else:
    return "Speaking extremely passionately"

# returns gender and the mood of speech
# Gender is either male or female
# Mood of speech is either showing no emotion, reading, or speaking passionately
def myspgender(m, p):

  try:
        file_data = run_praat_file(m, p)
        vocal_range_average = float(file_data[7])
        if 97 < vocal_range_average <= 163:
            return "Male"
        elif 163 < vocal_range_average <= 245:
            return "Female"
        else:
            return "Voice was not recognized"

  except Exception as e:
        print("The audio was not able to be computed, please try a different one")
        print(e)
  
  """try:
        file_data = run_praat_file(m, p)
        vocal_range_average = float(file_data[7])
        if 97 < vocal_range_average <= 114:
            return {"gender": "Male", "mood of speech": "Showing no emotion"}
        elif 114 < vocal_range_average <= 135:
            return {"gender": "Male", "mood of speech": "Reading"}
        elif 135 < vocal_range_average <= 163:
            return {"gender": "Male", "mood of speech": "Speaking passionately"}
        elif 163 < vocal_range_average <= 197:
            return {"gender": "Female", "mood of speech": "Showing no emotion"}
        elif 197 < vocal_range_average <= 226:
            return {"gender": "Female", "mood of speech": "Reading"}
        elif 226 < vocal_range_average <= 245:
            return {"gender": "Female", "mood of speech": "Speaking passionately"}
        else:
            return "Voice was not recognized"

    except Exception as e:
        print("The audio was not able to be computed, please try a different one")
        print(e)"""

# returns number of words per minute of speaking
def get_wpm(data, text):
    nlp = spacy.load("en_core_web_sm")
    doc = nlp(text)
    words = []
    for token in doc:
        if not token.is_punct:
            words.append(token.text)
    minutes = float(data['speaking_duration']) / 60
    wpm = len(words) / minutes
    return int(wpm)