import express from "express";

const app = express();

app.get('/', (req,res) => {
    res.send("Remotion Backend running for App")
})

app.listen(3000, () => {
    console.log("Backend running on http://localhost:3000");
})