console.log( 'Attemping fetch...' )
fetch( 'https://g1iil5rwc5.execute-api.eu-west-2.amazonaws.com/presignedurl' )
  .then( response => {
    if ( ! response.ok ) {
      throw new Error( 'Network response was not ok: ' + response.status );
    }
    return response.blob();
  })
  .then( myBlob => {
    //myImage.src = URL.createObjectURL(myBlob);
    console.log( myBlob );
  })
  .catch( error => {
    console.error( 'There has been a problem with your fetch operation:', error );
  });