import axios from 'axios';

const NEWS_API_KEY = "cc88834d0657444cbcf861e461dbb4f5";
const NEWS_URL = "https://newsapi.org/v2/everything";
const TRANSLATE_URL = "https://api.mymemory.translated.net/get";

export const fetchNews = async () => {
    try {
        const response = await axios.get(NEWS_URL, {
            params: {
                q: "law India OR legal news India OR supreme court india",
                sortBy: "publishedAt",
                language: "en",
                apiKey: NEWS_API_KEY
            }
        });
        return response.data.articles;
    } catch (error) {
        console.error("News API Error:", error);
        return [];
    }
};

export const translateText = async (text, targetLang) => {
    if (!targetLang || targetLang === 'English') return text;

    const langMap = {
        'Hindi': 'hi',
        'Tamil': 'ta',
        'Telugu': 'te',
        'Marathi': 'mr',
        'Malayalam': 'ml',
        'Kannada': 'kn',
        'Bengali': 'bn'
    };

    const langCode = langMap[targetLang] || 'hi';

    try {
        const response = await axios.get(TRANSLATE_URL, {
            params: {
                q: text,
                langpair: `en|${langCode}`
            }
        });
        return response.data.responseData.translatedText;
    } catch (error) {
        console.error("Translation Error:", error);
        return text;
    }
};
