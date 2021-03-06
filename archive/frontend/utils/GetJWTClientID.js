import React, { useState } from "react";
import { Button, ButtonGroup, Container } from "react-bootstrap";
import { useAuth0 } from "@auth0/auth0-react";

export const ExternalApi = () => {
  const [message, setMessage] = useState("");

  const { getAccessTokenSilently } = useAuth0();

  const callApi = async () => {
    try {
      const response = await fetch(`https://jjb2yw80q6.execute-api.eu-west-2.amazonaws.com/listobjects`);

      const responseData = await response.json();

      setMessage(responseData);
    } catch (error) {
      setMessage(error.message);
    }
  };

  const callSecureApi = async () => {
    try {
      const token = await getAccessTokenSilently();

      const response = await fetch(`https://jjb2yw80q6.execute-api.eu-west-2.amazonaws.com/listobjects`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      const responseData = await response.json();

      setMessage(responseData);
    } catch (error) {
      setMessage(error.message);
    }
  };

  return (
    <Container className="mb-5">
      <h1>External API</h1>
      <p>
        You use will use a button to call an external API using an access token,
        and the API will validate it using the API's audience value.{" "}
        <strong>This route should be private</strong>.
      </p>
      <ButtonGroup>
        <Button onClick={callApi} color="primary" className="mt-5">
          Get Public Message
        </Button>
        <Button onClick={callSecureApi} color="primary" className="mt-5">
          Get Private Message
        </Button>
      </ButtonGroup>

      {message && (
        <div className="mt-5">
          <h6 className="muted">Result</h6>
          {JSON.stringify(message, null, 2)}
        </div>
      )}
    </Container>
  );
};

export default ExternalApi;
