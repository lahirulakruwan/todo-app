const express = require('express');
const path = require('path');

const app = express();

// Serve Flutter project from the public-flutter directory
app.use(express.static(path.join(__dirname, 'public-flutter')));


// Start the server
// const PORT = process.env.PORT || 8080;
const PORT = 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
