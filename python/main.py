import os
from pathlib import Path
from myprosody import *
from flask import Flask, request, abort, jsonify
from speech2text import get_speech_info
from sentiment import get_sentences_sentiment

#
app = Flask(__name__)
app.config['UPLOAD_PATH'] = 'myprosody/dataset/essen/audioFiles'
app.config['UPLOAD_EXTENSIONS'] = ['.wav', '.mp3', '.m4a', '.wma', '.ogg']


# '/analize' is our route, ['GET', 'POST'] are our methods to support both HTTP request types
@app.route('/analyze', methods=['GET', 'POST'])
def analyze_audio():
    print(request.files)
    uploaded_file = request.files.getlist("song")[0]

    filename = uploaded_file.filename
    print(filename)
    if filename != '':
        # _ would contain root ("/Users/ryano/Downloads/audio"), video_file_extension would contain extension (".wav")
        _, video_file_extension = os.path.splitext(filename)
        print(_, video_file_extension)
        if video_file_extension not in app.config['UPLOAD_EXTENSIONS']:
            abort(400)

        # this will save our audio1
        #filename = os.path.join(app.config['UPLOAD_PATH'], filename)
        filename = app.config['UPLOAD_PATH'] + "/" + filename;
        print(filename)
        uploaded_file.save(filename)

        # filename_path will be used for running AI
        p = Path(filename).stem
        c = "myprosody"

        data = mysptotal(p, c)
        print(data)

        speech_info = get_speech_info(filename)
        #print(speech_info['text'])

        #wpm = get_wpm(data, speech_info['text'])
        wpm = 100
        #print(wpm)

        # print(speech_info['sentiment_analysis_results'])
        #response = get_sentences_sentiment(speech_info['sentiment_analysis_results'])
        #print(response)

        #wpm = str(wpm)
        refined_data = [str(wpm), data["gender"], data["mood"], data["original_duration"], data["speaking_duration"], data["number_of_pauses"], speech_info['text']]

        # deletes the file
        os.remove(filename)
        return jsonify(refined_data)


# code to run the app
if __name__ == "__main__":
    app.run(host='0.0.0.0')
