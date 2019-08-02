<script>
	const swatches = 'dry3,dry2,dry1,wet1,wet2,wet3'.split(',');
</script>

<div class="legend">
	<div class="swatches">
		{#each swatches as swatch}
		<div class="{swatch}"></div>
		{/each}
	</div>
	<div class="labels">
		<div>dryer than normal</div>
		<div>wetter than normal</div>
	</div>
</div>
<style>
	.swatches, .labels {
		display: flex;
	}
	.swatches div {
		flex-grow: 1;
		height: 1ex;
	}
	.labels div {
		font-weight: bold;
		font-size: 14px;
		flex-grow: 1;
		color: #b35806;;
	}
	.labels div:last-child {
		text-align: right;
		color: #2166ac;
	}
    .dry3 { background: #b35806; }
    .dry2 { background: #f1a340; }
    .dry1 { background: #fee0b6; }
    .wet3 { background: #2166ac; }
    .wet2 { background: #67a9cf; }
    .wet1 { background: #d1e5f0; }
</style>
