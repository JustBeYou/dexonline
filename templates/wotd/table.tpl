{extends "layout-admin.tpl"}

{block "title"}Cuvântul zilei{/block}

{block "content"}

  <h3>Cuvântul zilei</h3>

  <table id="wotdGrid" class="table"></table>
  <div id="wotdPaging"></div>

  <select id="imageList">
    {foreach $imageList as $image}
      <option value="{$image}">{$image}</option>
    {/foreach}
  </select>

  <div class="card my-3">
    <div class="card-header">Legături</div>

    <ul class="list-group list-group-flush">

      <li class="list-group-item">
        asistent CZ:
        {foreach $assistantDates as $timestamp}
          <a
            class="ms-3"
            href="{Router::link('wotd/assistant')}?for={$timestamp|date_format:"%Y-%m"}">
            {$timestamp|date_format:"%B %Y"}
          </a>
        {/foreach}
      </li>

      <li class="list-group-item">
        <a href="{Router::link('wotd/images')}">imagini pentru cuvântul zilei</a>
      </li>

      <li class="list-group-item">
        <a href="https://wiki.dexonline.ro/wiki/Imagini_pentru_cuv%C3%A2ntul_zilei">instrucțiuni</a>
      </li>

    </ul>
  </div>

{/block}
