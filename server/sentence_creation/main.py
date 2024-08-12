from fastapi import FastAPI, Body, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import nltk
from nltk.tokenize import word_tokenize
from nltk.tag import pos_tag
import language_tool_python

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


tool = language_tool_python.LanguageTool('en-US')

def create_sentence(words: str):
    try:
        words = words.replace("me", "I")

        tagged_words = pos_tag(word_tokenize(words))

        sentence = ""
        previous_tag = None

        for word, tag in tagged_words:
            if tag.startswith('NN'):
                if previous_tag is None:
                    sentence += "The " + word + " "
                else:
                    sentence += word + " "
            elif tag.startswith('VB'):
                if previous_tag and previous_tag.startswith('NN'):
                    sentence += "is " + word + " "
                else:
                    sentence += word + " "
            elif tag.startswith('JJ'):
                sentence += word + " "
            elif tag.startswith('RB'):
                sentence += word + " "

            previous_tag = tag

        sentence = sentence.strip()

        if sentence:
            sentence = sentence[0].upper() + sentence[1:]

        corrected_sentence = tool.correct(sentence)

        return corrected_sentence
    except Exception as e:
        return f"Error: Sentence creation failed. Reason: {e}"

@app.post("/create-sentence")
async def generate_sentence(words: dict = Body(...)):
    words = words.get("words", "")
    if not words:
        raise HTTPException(status_code=400, detail="Input cannot be empty")
    sentence = create_sentence(words)
    return {"sentence": sentence}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="192.168.1.4", port=8000, reload=True)
