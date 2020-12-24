import React, { useState } from "react";
 import { Button, ButtonGroup, Container } from "react-bootstrap";
import { useAuth0 } from '@auth0/auth0-react';

const GetProtectedResourceButton = () => {
  const [image, setImage] = useState("");

    const { isAuthenticated } = useAuth0();

    const callSecureApi = () => {
      const cloudfrontDistribution = process.env.REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME;
      setImage(<img src={`https://${cloudfrontDistribution}/media/6cg02pf.jpeg`}></img>)
    }
    
    
    return (
        isAuthenticated && (
          <Container>
                    <ButtonGroup>
        <Button onClick={callSecureApi} color="primary" className="mt-5">
          Show Highly Secure Image
        </Button>
      </ButtonGroup>

              {image}


      </Container>

        )
    )
}

export default GetProtectedResourceButton