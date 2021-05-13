import React, { useState } from 'react'

const REACT_APP_AUTH0_DOMAIN = localStorage.getItem('REACT_APP_AUTH0_DOMAIN')
const REACT_APP_AUTH0_CLIENT_ID = localStorage.getItem('REACT_APP_AUTH0_CLIENT_ID')
const REACT_APP_AUTH0_AUDIENCE = localStorage.getItem('REACT_APP_AUTH0_AUDIENCE')
const REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME = localStorage.getItem('REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME')

interface IState {
  REACT_APP_AUTH0_DOMAIN: string;
  REACT_APP_AUTH0_CLIENT_ID: string;
  REACT_APP_AUTH0_AUDIENCE: string;
  REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME: string;
}

interface SetupProps {
  firstSetup?: boolean
}

export const Setup: React.FC<SetupProps> = (firstSetup) => {

  const [myState, setMyState] = useState<IState>({
    REACT_APP_AUTH0_AUDIENCE: REACT_APP_AUTH0_AUDIENCE || "",
    REACT_APP_AUTH0_CLIENT_ID: REACT_APP_AUTH0_CLIENT_ID || "",
    REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME: REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME || "",
    REACT_APP_AUTH0_DOMAIN: REACT_APP_AUTH0_DOMAIN || ""
  })

  const [saved, setSaved] = useState(false)

  const onChange=(e: any): void => {
    const { name, value } = e.currentTarget;
    setMyState({ ...myState, [name]: value });
    console.log(`Setting state ${name} to ${value}`)

    setSaved(false)
  }

  const onSubmit=(e: React.FormEvent): void => {
    e.preventDefault()

    console.log("Submitting")
    localStorage.setItem('REACT_APP_AUTH0_DOMAIN', myState.REACT_APP_AUTH0_DOMAIN);
    localStorage.setItem('REACT_APP_AUTH0_CLIENT_ID', myState.REACT_APP_AUTH0_CLIENT_ID);
    localStorage.setItem('REACT_APP_AUTH0_AUDIENCE', myState.REACT_APP_AUTH0_AUDIENCE);
    localStorage.setItem('REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME', myState.REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME);
    setSaved(true)
  }

  
  return (
    <div>
      <p>Before you can access your media, Violet needs to know some details.</p>
      <form onSubmit={onSubmit}>
      <p>
          <label htmlFor="REACT_APP_AUTH0_DOMAIN">Auth0 domain</label>
          <input onChange={onChange} type="text" id="REACT_APP_AUTH0_DOMAIN" name="REACT_APP_AUTH0_DOMAIN" value={myState.REACT_APP_AUTH0_DOMAIN} />
        </p>
        <p>
          <label htmlFor="REACT_APP_AUTH0_CLIENT_ID">Auth0 client ID</label>
          <input onChange={onChange} type="text" id="REACT_APP_AUTH0_CLIENT_ID" name="REACT_APP_AUTH0_CLIENT_ID" value={myState.REACT_APP_AUTH0_CLIENT_ID} />
        </p>
        <p>
          <label htmlFor="REACT_APP_AUTH0_AUDIENCE">Auth0 audience (API endpoint)</label>
          <input onChange={onChange} type="text" id="REACT_APP_AUTH0_AUDIENCE" name="REACT_APP_AUTH0_AUDIENCE" value={myState.REACT_APP_AUTH0_AUDIENCE} />
        </p>
        <p>
          <label htmlFor="REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME">CloudFront distribution domain name</label>
          <input onChange={onChange} type="text" id="REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME" name="REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME" value={myState.REACT_APP_CLOUDFRONT_DISTRIBUTION_DOMAIN_NAME} />
        </p>
        <div className="buttonWithMessage">
          <button disabled={saved ? true : false} type="submit">Save</button>
          {saved && <span>Changes saved.</span>}
          <a href="/" className="formContinue">Continue to Violet</a>
          </div>
      </form>
    </div>
  );
}

export default Setup;
