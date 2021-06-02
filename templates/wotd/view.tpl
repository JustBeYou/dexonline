{extends "layout.tpl"}

{block "title"}
  {cap}{t}word of the day{/t}{/cap} ({$day} {$monthName} {$year}):
  {$searchResult->definition->lexicon}
{/block}

{block "pageDescription"}
  {$lexicon=$searchResult->definition->lexicon}
  <meta
    name="description"
    content="Cuvântul zilei de {$day} {$monthName} {$year} la dexonline: {$lexicon}">
{/block}

{block "openGraph"}
  {* Nothing -- so crawlers index the image of the day instead. *}
{/block}

{block "content"}
  {assign var="reason" value=$reason|default:''}

  <h3>
    {t 1=$day 2=$monthName 3=$year}Word of the day for %2 %1, %3{/t}

    {if Config::SKIN_WOTD_SUBSCRIBE}
      <div id="wotdSocialMedia" class="float-end">
        <div>
          <a href="#toggleContents" data-bs-toggle="collapse">
            <img src="{Config::URL_PREFIX}img/social-media/email-29.png" alt="iconiță email"
          ></a>
          <a type="application/rss+xml" href="{Router::link('wotd/rss')}">
            <img src="{Config::URL_PREFIX}img/social-media/rss-29.png" alt="iconiță RSS"
          ></a>
          <a href="https://www.facebook.com/dexonline">
            <img src="{Config::URL_PREFIX}img/social-media/facebook-29.png" alt="iconiță Facebook"
          ></a>
        </div>
      </div>
    {/if}
  </h3>

  <div id="toggleContents" class="collapse voffset2">
    <div class="card mb-3">
      <div class="card-body">
        {t
          1="http://www.google.com/search?q=rss+by+email"
          2="https://blogtrottr.com/"
        }<i>dexonline</i> does not directly offer the word of the day by email.
        However, there are <a href="%1">many sites</a> that do this for any RSS feed.
        We recommend <a href="%2">Blogtrottr</a>.{/t}
      </div>
    </div>
  </div>

  <div class="card mb-4">
    <div class="card-header fs-2 px-2 py-0 d-flex justify-content-between">
      {if $prevDay}
        <a href="{Router::link('wotd/view')}/{$prevDay}">
          {include "bits/icon.tpl" i=chevron_left}
        </a>
      {/if}
      {if $nextDay}
        <a href="{Router::link('wotd/view')}/{$nextDay}">
          {include "bits/icon.tpl" i=chevron_right}
        </a>
      {/if}
    </div>

    <div class="card-body pb-0">
      <a {if $wotd->url}href="{$wotd->url}"{/if} target="_blank">
        <img class="img-fluid mx-auto d-block"
          src="{$wotd->getLargeThumbUrl()}"
          alt="{$searchResult->definition->lexicon}"
          title="{$searchResult->definition->lexicon}">
      </a>
      <div class="text-muted text-end">
        {$wotd->getArtist()->credits|default:''}
      </div>

      {if $wotd->sponsor}
        {include "wotd-sponsors/{$wotd->sponsor}"}
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

  {if Config::SKIN_WOTD_ARCHIVE}
    <h3>{t}Word of the day archive{/t}</h3>

    <div id="wotdArchive" class="wotdArchive"></div>
    <script>
      loadAjaxContent(
        "{Router::link('wotd/archive')}/{$year}/{$month}",
        '#wotdArchive');
    </script>

    <h3>
      {t 1=$day 2=$monthName}Word of the day for %2 %1 in other years:{/t}
    </h3>
    {foreach $otherYears as $r}
      <div class="card mb-3">
        <div class="card-body">
          <img class="ms-3 float-end"
               src="{$r.wotd->getMediumThumbUrl()}"
               alt="iconița cuvântului zilei">
          <p>
            <strong>{$r.wotd->displayDate|date_format:'%Y'}</strong>:
            <a href="{Router::link('wotd/view')}/{$r.wotd->getUrlDate()}">
              {$r.word}
            </a>
          </p>
          {$r.wotd->description}
        </div>
      </div>
    {/foreach}
  {/if}

{/block}
