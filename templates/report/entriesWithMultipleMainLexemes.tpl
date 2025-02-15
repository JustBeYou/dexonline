{assign var="withCharmap" value=false scope=parent}
{extends "layout-admin.tpl"}

{block "title"}Intrări cu discrepanțe la lexemele principale{/block}

{block "content"}

  <h3>
    Intrări cu discrepanțe la lexemele principale
    {if count($entries) == $numEntries}
      ({$numEntries})
    {else}
      ({$entries|count} din {$numEntries} afișate)
    {/if}
  </h3>

  <p>
    Sunt listate intrările pentru care numărul de lexeme principale și bifa
    „lexeme principale multiple” sunt în dezacord. Puteți edita valorile
    bifelor (nu uitați să salvați la final).
  </p>

  {if count($entries)}
    <form method="post">
      <table id="entries" class="table table-striped table-bordered" role="grid">
        <thead>
          <tr>
            <th scope="col" data-column-id="description">descriere</th>
            <th class="text-center" scope="col" data-column-id="lexemes">bifă</th>
            <th scope="col" data-column-id="lexemes">lexeme</th>
            <th class="text-right" scope="col" data-column-id="modified">modificată</th>
            <th class="text-right" scope="col" data-column-id="modDate">la data</th>
          </tr>
        </thead>
        <tbody>
          {foreach $entries as $e}
            {include "bits/entryRow.tpl"}
          {/foreach}
        </tbody>
      </table>

      <button type="submit" class="btn btn-primary" name="saveButton">
        <i class="glyphicon glyphicon-floppy-disk"></i>
        <u>s</u>alvează
      </button>
    </form>

    <script>
      $(document).ready(function() {
        $('#entries').tablesorter();
      });
    </script>
  {/if}

{/block}
