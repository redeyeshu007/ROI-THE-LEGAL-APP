import axios from 'axios';

const GROQ_API_KEY = "REPLACE_WITH_YOUR_GROQ_API_KEY";
const GROQ_URL = "https://api.groq.com/openai/v1/chat/completions";

export const getSystemPrompt = (mode, lang) => {
    if (mode === 'voice') {
        return `You are VIDDHI, an Indian legal AI assistant for voice conversations. 
    IMPORTANT: Reply ONLY in the ${lang} language. 
    Give clear, conversational answers in 3-5 sentences. PLAIN TEXT ONLY. 
    DO NOT use any markdown symbols like **. Cite Article/Section numbers. 
    Always add: "This is educational, not formal legal advice."`;
    }
    return `You are NEEDHi, an expert Indian Constitution and legal tutor. 
  IMPORTANT: Reply ONLY in the ${lang} language. 
  STRICT RULE: Give detailed, well-structured answers in PLAIN TEXT ONLY. 
  DO NOT use **bolding**, *italics*, or any markdown symbols. 
  Use numbered lists (1. 2. 3.) for steps and Article/Section numbers. 
  Cover: definition, explanation in simple ${lang}, real-world example, and legal procedure. 
  Mention both IPC and BNS. End with: "This is for educational purposes, not formal legal advice."`;
};

export const callGroq = async (userText, mode, lang, history = []) => {
    const systemPrompt = getSystemPrompt(mode, lang);

    const messages = [
        { role: "system", content: systemPrompt },
        ...history,
        { role: "user", content: userText }
    ];

    try {
        const response = await axios.post(GROQ_URL, {
            model: "llama-3.3-70b-versatile",
            messages,
            temperature: 0.7,
            max_tokens: 1024,
        }, {
            headers: {
                'Authorization': `Bearer ${GROQ_API_KEY}`,
                'Content-Type': 'application/json'
            }
        });

        return response.data.choices[0].message.content;
    } catch (error) {
        console.error("Groq API Error:", error);
        throw error;
    }
};
