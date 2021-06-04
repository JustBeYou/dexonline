{extends "layout.tpl"}

{block "title"}
  {t}Word of the month for{/t} {$timestamp|date_format:'%B %Y'}:
  {$searchResult->definition->lexicon}
{/block}

{block "pageDescription"}
  <meta
    name="description"
    content="Cuvântul lunii {$timestamp|date_format:'%B %Y'} la dexonline: {$searchResult->definition->lexicon}">
{/block}

{block "openGraph"}
  {* Nothing -- so crawlers index the image of the month instead. *}
{/block}

{block "content"}
  <h3>{t}Word of the month for{/t} {$timestamp|date_format:'%B %Y'}</h3>
  <div class="card mb-3">
    <div class="card-header fs-2 px-2 py-0 d-flex justify-content-between">
      {if isset($prevmon)}
        <a title="{t}previous{/t}" href="{Router::link('wotm/view')}/{$prevmon}">
          {include "bits/icon.tpl" i=chevron_left}
        </a>
      {/if}
      {if isset($nextmon)}
        <a title="{t}next{/t}" href="{Router::link('wotm/view')}/{$nextmon}">
          {include "bits/icon.tpl" i=chevron_right}
        </a>
      {/if}
    </div>

    <div class="card-body pb-0">

      {if $imageUrl}
        <img
          class="img-fluid mx-auto d-block"
          src="{$imageUrl}"
          alt="{$searchResult->definition->lexicon}"
          title="{$searchResult->definition->lexicon}">
        <div class="text-muted text-end">
          {$artist->credits|default:''}
        </div>
      {/if}

      {include "bits/definition.tpl"
        row=$searchResult
        showBookmark=1
        showCourtesyLink=1
        showFlagTypo=1
        showHistory=1}

    </div>
    {if $reason}
      <div class="card-footer">
        <b>{t}Chosen because:{/t}</b> {$reason}
      </div>
    {/if}
  </div>
{/block}
