<script>
	export let name;

	let promise = getRandomNumber();

	async function getRandomNumber() {
		const res = await fetch("https://jsonplaceholder.typicode.com/todos/1");
		const text = await res.text();

		if (res.ok) {
			return text;
		} else {
			throw new Error(text);
		}
	}

	function handleClick() {
		promise = getRandomNumber();
	}

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
</script>

<main>
	<h1>Hello {name}!</h1>
	<p>Visit the <a href="https://svelte.dev/tutorial">Svelte tutorial</a> to learn how to build Svelte apps.</p>

	<button on:click={handleClick}>
	generate random number
	</button>

	{#await promise}
	<p>...waiting</p>
	{:then number}
		<p>The number is {number}</p>
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