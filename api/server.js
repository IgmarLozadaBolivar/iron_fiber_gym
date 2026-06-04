import "dotenv/config";
import express from 'express'

const app = express()
const port = process.env.APP_PORT

app.get('/health', (req, res) => {
    res.json({
        status: `Conexión establecida con ${process.env.DB_NAME}.`
    })
})

app.listen(port, () => {
    console.log(`Servidor disponible en: ${process.env.APP_URL}:${port}`)
})