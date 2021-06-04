{extends "layout-admin.tpl"}

{block "title"}Lista Oficială de Cuvinte{/block}

{block "content"}
  <h3>
    Diferențe între LOC {$versions.0} și LOC {$versions.1} ({$listType})
  </h3>

  <p>
    <a class="btn btn-light" href="{Router::link('games/scrabble')}">
      <i class="glyphicon glyphicon-chevron-left"></i>
      înapoi
    </a>
    <a class="btn btn-light" href="{$zipUrl}">
      <i class="glyphicon glyphicon-download-alt"></i>
      descarcă
    </a>
  </p>

  {strip}
  <pre class="locDiff">
    {foreach $diff as $rec}
      <div class="{if $rec.0 == 'ins'}text-success{else}text-danger{/if}">
        {$rec.1}
      </div>
    {/foreach}
  </pre>
  {/strip}
{/block}
