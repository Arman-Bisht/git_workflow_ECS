# Simple Node.js server for testing ECS Fargate deployment
FROM node:18-alpine

WORKDIR /app

# Create a simple Express server
RUN npm install express

# Create server file
RUN echo 'const express = require("express");\n\
const app = express();\n\
const PORT = process.env.PORT || 1337;\n\
\n\
app.get("/", (req, res) => {\n\
  res.json({\n\
    message: "Task 7: ECS Fargate Deployment Successful!",\n\
    timestamp: new Date().toISOString(),\n\
    environment: process.env.NODE_ENV || "development"\n\
  });\n\
});\n\
\n\
app.get("/health", (req, res) => {\n\
  res.json({ status: "healthy" });\n\
});\n\
\n\
app.listen(PORT, "0.0.0.0", () => {\n\
  console.log(`Server running on port ${PORT}`);\n\
});\n\
' > server.js

EXPOSE 1337

CMD ["node", "server.js"]
