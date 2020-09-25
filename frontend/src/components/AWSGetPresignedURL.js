import React, { useState, useEffect } from 'react';
import { useAuth0 } from '@auth0/auth0-react';

const {
  isAuthenticated,
  getAccessTokenSilently,
  loginWithPopup,
  getAccessTokenWithPopup,
} = useAuth0();

const AWSGetPresignedURL = () => {

  const [state, setState] = useState({
    showResult: false,
    apiMessage: "",
    error: null,
  });

  const handleConsent = async () => {
    try {
      await getAccessTokenWithPopup();
      setState({
        ...state,
        error: null,
      });
    } catch (error) {
      setState({
        ...state,
        error: error.error,
      });
    }

    await callApi();
  };

  const handleLoginAgain = async () => {
    try {
      await loginWithPopup();
      setState({
        ...state,
        error: null,
      });
    } catch (error) {
      setState({
        ...state,
        error: error.error,
      });
    }

    await callApi();
  };

  const callApi = async () => {
    try {
      const token = await getAccessTokenSilently();

      const response = await fetch(`https://jjb2yw80q6.execute-api.eu-west-2.amazonaws.com/listobjects`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      const responseData = await response.json();

      setState({
        ...state,
        showResult: true,
        apiMessage: responseData,
      });
    } catch (error) {
      setState({
        ...state,
        error: error.error,
      });
    }
  };

  const handle = (e, fn) => {
    e.preventDefault();
    fn();
  };



    return (
        isAuthenticated && (
            <div>

                <h3>User Metadata</h3>
            </div>
        )
    )

}

export default AWSGetPresignedURL