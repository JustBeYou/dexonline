{extends "layout-admin.tpl"}

{block "title"}Editare flexiuni{/block}

{block "content"}
  <h3>Editare flexiuni</h3>

  <p class="alert alert-info">
    <strong>Instrucțiuni:</strong> Trageți de rânduri pentru a le reordona, apoi apăsați
    <em>Salvează</em>. Puteți șterge doar flexiunile nefolosite (de obicei, cele nou create).
  </p>

  <form method="post">
    <table id="inflections" class="table table-sm table-hover">
      <thead>
        <tr>
          <th>Descriere</th>
          <th>Tip de model</th>
          <th>Ordinea inițială</th>
          <th>Șterge</th>
        </tr>
      </thead>

      <tbody>
        {foreach $inflections as $infl}
          <tr>
            <td class="nick">
              <input type="hidden" name="inflectionIds[]" value="{$infl->id}">
              {$infl->description}
            </td>
            <td>{$infl->modelType}</td>
            <td>{$infl->rank}</td>
            <td>{if $infl->canDelete}<a href="?deleteInflectionId={$infl->id}">șterge</a>{/if}</td>
          </tr>
        {/foreach}
        <tr>
          <td class="nick">
            <input type="text" name="newDescription" value="" class="form-control" placeholder="Adaugă">
          </td>
          <td>
            <select class="form-select" name="newModelType">
              {foreach $modelTypes as $mt}
                <option value="{$mt->code|escape}">{$mt->code|escape}</option>
              {/foreach}
            </select>
          </td>
          <td></td>
          <td></td>
        </tr>
      </tbody>
    </table>

    <button type="submit" name="saveButton" class="btn btn-primary">
      {include "bits/icon.tpl" i=save}
      <u>s</u>alvează
    </button>

  </form>

  <script>
    $(function() {
      $("#inflections").tableDnD();
    });
  </script>
{/block}
