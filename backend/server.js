const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const bcrypt = require("bcrypt");

const app = express();
app.use(bodyParser.json());
app.use(cors());

// Mock "database" with one user (password hashed)
const users = [];
(async () => {
  const hash = await bcrypt.hash("password123", 10);
  users.push({
    id: 1,
    email: "divaa@example.com",
    password: hash,
    name: "Divaa",
  });
})();

app.post("/api/login", async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ message: "Email and password required" });

  const user = users.find((u) => u.email === email);
  if (!user) return res.status(401).json({ message: "Email tidak terdaftar" });

  const match = await bcrypt.compare(password, user.password);
  if (!match) return res.status(401).json({ message: "Password salah" });

  // In real app: sign JWT token. For demo, return simple payload
  res.json({
    message: "Login Berhasil",
    userId: user.id,
    name: user.name,
    token: "demo-token-123",
  });
});

app.listen(3000, "0.0.0.0", () =>
  console.log("Server berjalan di http://localhost:3000"),
);
