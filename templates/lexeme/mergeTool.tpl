{extends "layout-admin.tpl"}

{block "title"}Unificare lexeme{/block}

{block "content"}
  <h3>Unificare lexeme - {$lexemes|@count} rezultate</h3>

  <div class="alert alert-info alert-dismissible" role="alert">
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>

    Pentru fiecare lexem la plural sunt indicate lexemele la singular
    corespunzătoare. Bifați unul sau mai multe, după caz. Puteți salva
    pagina în orice moment; lexemele rămase vor fi afișate din nou la
    reîncărcarea paginii. Pentru moment, nu există o modalitate de a
    „ignora” un lexem. Lexemele pe care nu le unificați vor apărea mereu
    în listă.
  </div>

  <form class="form-inline">
    <div class="form-group">
      <label>tipul lexemului</label>
      <select name="modelType" class="form-control">
        <option value="">Toate (lent)</option>
        <option value="M" {if $modelType == 'M'}selected{/if}>M</option>
        <option value="F" {if $modelType == 'F'}selected{/if}>F</option>
        <option value="N" {if $modelType == 'N'}selected{/if}>N</option>
        <option value="T" {if $modelType == 'T'}selected{/if}>T (lent)</option>
      </select>
    </div>
    <button type="submit" class="btn btn-primary">
      filtrează
    </button>
  </form>

  <form class="voffset4" method="post">
    <input type="hidden" name="modelType" value="{$modelType}">

    {foreach $lexemes as $lIter => $l}
      <div class="panel panel-default">

        <div class="panel-heading">
          {$lIter+1}. <strong>{$l->form|escape}</strong>
          {$l->modelType}{$l->modelNumber}{$l->restriction}
          <a href="{Router::link('lexeme/edit')}?lexemeId={$l->id}" class="btn btn-link">
            <i class="glyphicon glyphicon-pencil"></i>
            editează
          </a>
          <a href="#"
             class="defToggle btn btn-link"
             data-lexeme-id="{$l->id}"
             data-div-id="def_{$l->id}">
            <i class="glyphicon glyphicon-folder-open"></i>
            arată definițiile
          </a>
        </div>

        <div class="panel-body panel-admin">
          <div class="well" id="def_{$l->id}"></div>

          <div class="form-group">

            {foreach $l->matches as $match}
              <div class="checkbox">
                {assign var="checkboxId" value="merge_`$l->id`_`$match->id`"}
                <label>
                  <input type="checkbox" name="{$checkboxId}" value="1">
                  Unifică cu <strong>{$match->form}</strong>
                  {$match->modelType}{$match->modelNumber}{$match->restriction}
                </label>

                <a href="{Router::link('lexeme/edit')}?lexemeId={$match->id}" class="btn btn-link">
                  <i class="glyphicon glyphicon-pencil"></i>
                  editează
                </a>

                <a href="#"
                   class="defToggle btn btn-link"
                   data-lexeme-id="{$match->id}"
                   data-div-id="def_{$match->id}">
                  <i class="glyphicon glyphicon-folder-open"></i>
                  arată definițiile
                </a>
              </div>

              {if $match->lostForms}
                <ul>
                  <li>
                    Următoarele forme se vor pierde:
                    {foreach $match->lostForms as $form}
                      {$form}
                    {/foreach}
                  </li>
                </ul>
              {/if}
              <div class="well" id="def_{$match->id}"></div>
            {/foreach}
          </div>
        </div>
      </div>
    {/foreach}

    <button type="submit" class="btn btn-success" name="saveButton">
      <i class="glyphicon glyphicon-floppy-disk"></i>
      <u>s</u>alvează
    </button>
  </form>
{/block}
