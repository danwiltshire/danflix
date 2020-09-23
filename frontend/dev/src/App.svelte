<script>
	import {
	Auth0Context,
	authError,
	authToken,
	idToken,
	isAuthenticated,
	isLoading,
	login,
	logout,
	userInfo,
	} from '@dopry/svelte-auth0';

	export let name;

	let promise = getPresignedURL();

	function handleClick() {
		promise = getPresignedURL();
	}
	
	async function getPresignedURL() {
		console.log( 'Attemping fetch...' )
		const res = await fetch( "https://g1iil5rwc5.execute-api.eu-west-2.amazonaws.com/presignedurl" );
		const text = await res.text();

		if ( ! res.ok ) {
			throw new Error( 'Network response was not ok: ' + res.status );
		} else {
			console.log( 'Fetch successful, returning...' )
			return text
		}
	}
</script>

<main>

	  <Auth0Context
		domain="dwlab.eu.auth0.com"
		client_id="AplO6ha5bKxMxKL7f6fXAYtCJtC2NGsa"
		audience="http://localhost:5000"
	>

	<button class="btn" on:click|preventDefault='{() => login() }'>Login</button>
  <button class="btn" on:click|preventDefault='{() => logout() }'>Logout</button>
  <table>
    <thead>
      <tr><th>store</th><th>value</th></tr>
    </thead>
    <tbody>
      <tr><td>isLoading</td><td>{$isLoading}</td></tr>
      <tr><td>isAuthenticated</td><td>{$isAuthenticated}</td></tr>
      <tr><td>authToken</td><td>{$authToken}</td></tr>
      <tr><td>idToken</td><td>{$idToken}</td></tr>
      <tr><td>userInfo</td><td><pre>{JSON.stringify($userInfo, null, 2)}</pre></td></tr>
      <tr><td>authError</td><td>{$authError}</td></tr>
    </tbody>
  </table>
</Auth0Context>

	  
	<h1>Hello {name}!</h1>
	<p>Visit the <a href="https://svelte.dev/tutorial">Svelte tutorial</a> to learn how to build Svelte apps.</p>

	<button on:click={handleClick}>
	Get presigned URL
	</button>

	{#await promise}
	<p>...waiting</p>
	{:then url}
		<p>The url is {url}</p>
	{:catch error}
		<p style="color: red">{error.message}</p>
	{/await}
</main>

<style>
	main {
		text-align: center;
		padding: 1em;
		max-width: 240px;
		margin: 0 auto;
	}

	h1 {
		color: #ff3e00;
		text-transform: uppercase;
		font-size: 4em;
		font-weight: 100;
	}

	@media (min-width: 640px) {
		main {
			max-width: none;
		}
	}
</style>