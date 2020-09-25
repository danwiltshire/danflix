import React, { useState } from "react";
import { Button, ButtonGroup, Container } from "react-bootstrap";
import { useAuth0 } from "@auth0/auth0-react";
import JSONPretty from "react-json-pretty";

export const ListStorage = () => {
  const [messages, setMessage] = useState("");

  const { getAccessTokenSilently } = useAuth0();

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
      <ButtonGroup>
        <Button onClick={callSecureApi} color="primary" className="mt-5">
          List Storage
        </Button>
      </ButtonGroup>

      {messages && (
        <div className="mt-5">
          <h6 className="muted">Result</h6>

          { messages.map((message) => (
          
              <a href={"https://jjb2yw80q6.execute-api.eu-west-2.amazonaws.com/presignedurl?key=" + message.Key} key={message.Key}>{message.Key}</a>

          ))}

          <JSONPretty data={messages} onJSONPrettyError={e => console.error(e)}></JSONPretty>
        </div>
      )}
    </Container>
  );

};

export default ListStorage;
