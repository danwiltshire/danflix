fetch('https://g1iil5rwc5.execute-api.eu-west-2.amazonaws.com/presignedurl')
  .then(response => response.json())
  .then(data => console.log(data));