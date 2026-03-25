const normalizeName = (name) => {
  return name.trim();
};

const buildLabel = (user) => {
  return `${user.id}:${user.name}`;
};

const addScore = (score, delta) => {
  return score + delta;
};

const joinLines = (lines) => {
  return lines.join("\n");
};

module.exports = { normalizeName, buildLabel, addScore, joinLines };
