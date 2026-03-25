const greeting = (name) => {
  return `Hello, ${name}!`;
};

const formatUser = (user) => {
  return `${user.id}:${user.name}`;
};

const sum = (a, b) => {
  return a + b;
};

const toCsv = (rows) => {
  return rows.join("\n");
};

module.exports = { greeting, formatUser, sum, toCsv };
