const greet = (name) => {
  return `Hello, ${name}!`;
};

const sum = (a, b) => {
  return a + b;
};

const logUser = (user) => {
  console.log(`User: ${user.id} ${user.name}`);
};

module.exports = { greet, sum, logUser };
