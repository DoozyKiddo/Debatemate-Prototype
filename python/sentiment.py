# returns text and sentiment of each sentence
def get_sentences_sentiment(sentiment_analysis):
    sentences = []
    for sentence in sentiment_analysis:
        data = {'text': sentence['text'], 'sentiment': sentence['sentiment']}
        sentences.append(data)

    return sentences
