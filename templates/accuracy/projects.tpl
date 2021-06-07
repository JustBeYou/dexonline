{extends "layout-admin.tpl"}

{block "title"}Verificarea acurateței{/block}

{block "content"}
  <h3>Verificarea acurateței</h3>

  <div class="card mb-3">
    <div class="card-header">Proiectele mele</div>

    <div class="card-body">
      <div class="form-check">
        <label class="form-check-label">
          <input
            type="checkbox"
            class="form-check-input"
            id="includePublic"
            {if $includePublic}checked{/if}
            value="1">
          include proiectele publice ale altor moderatori
        </label>
      </div>
    </div>

    <table id="projectTable" class="table tablesorter ts-pager mb-0">

      <thead>
        <tr>
          <th>nume</th>
          <th>autor proiect</th>
          <th>editor</th>
          <th>sursă</th>
          <th>definiții</th>
          <th>erori/KB</th>
          <th>car/oră</th>
        </tr>
      </thead>

      <tbody>
        {foreach $projects as $proj}
          <tr>
            <td><a href="{Router::link('accuracy/eval')}?projectId={$proj->id}">{$proj->name}</a></td>
            <td>{$proj->getOwner()}</td>
            <td>{$proj->getUser()}</td>
            <td>{$proj->getSource()->shortName|default:'&mdash;'}</td>
            <td data-text="{$proj->defCount}">{$proj->defCount|nf}</td>
            <td data-text="{$proj->getErrorsPerKb()}">{$proj->getErrorsPerKb()|nf:2}</td>
            <td data-text="{$proj->getCharactersPerHour()}">{$proj->getCharactersPerHour()|nf}</td>
          </tr>
        {/foreach}
      </tbody>

      {include "bits/pager.tpl" id="projectPager" colspan="7"}
    </table>
  </div>

  <div class="card mb-3">
    <div class="card-header">Creează un proiect nou</div>
    <div class="card-body">

      <form method="post">

        <div class="row mb-2">
          <label for="f_name" class="col-lg-3 col-form-label">nume</label>
          <div class="col-lg-9">
            <input type="text" id="f_name" class="form-control" name="name" value="{$p->name}">
          </div>
        </div>

        <div class="row mb-2">
          <label class="col-lg-3 col-form-label">utilizator</label>
          <div class="col-lg-9">
            <select name="userId" class="form-select select2Users">
              <option value="{$p->userId}" selected></option>
            </select>
          </div>
        </div>

        <div class="row mb-2">
          <label for="f_length" class="col-lg-3 col-form-label">lungime</label>
          <div class="col-lg-9">
            <input type="number"
              id="f_length"
              class="form-control"
              name="length"
              value="{$length}">
            <div class="form-text">
              lungimea totală a definițiilor pe care doriți să le evaluați
            </div>
          </div>
        </div>

        <div class="row mb-2">
          <label for="sourceDropDown" class="col-lg-3 col-form-label">sursă (opțional)</label>
          <div class="col-lg-9">
            {include "bits/sourceDropDown.tpl" name="sourceId" sourceId=$p->sourceId}
          </div>
        </div>

        <div class="row mb-2">
          <label for="f_prefix" class="col-lg-3 col-form-label">prefix (opțional)</label>
          <div class="col-lg-9">
            <input type="text"
              id="f_prefix"
              class="form-control"
              name="lexiconPrefix"
              value="{$p->lexiconPrefix}">
            <div class="form-text">
              selectează doar definiții care încep cu acest prefix
            </div>
          </div>
        </div>

        <div class="row mb-2">
          <label for="f_startDate" class="col-lg-3 col-form-label">dată de început (opțional)</label>
          <div class="col-lg-9">
            <input
              type="text"
              id="f_startDate"
              name="startDate"
              value="{$p->startDate}"
              class="form-control"
              placeholder="AAAA-LL-ZZ">
          </div>
        </div>

        <div class="row mb-2">
          <label for="f_endDate" class="col-lg-3 col-form-label">dată de sfârșit (opțional)</label>
          <div class="col-lg-9">
            <input
              type="text"
              id="f_endDate"
              name="endDate"
              value="{$p->endDate}"
              placeholder="AAAA-LL-ZZ"
              class="form-control">
          </div>
        </div>

        <div class="row mb-2">
          <label class="col-lg-3 col-form-label">vizibilitate</label>
          <div class="col-lg-9">
            {include "bits/dropdown.tpl"
              name="visibility"
              data=AccuracyProject::VIS_NAMES
              selected=$p->visibility}
          </div>
        </div>

        <div class="row mb-2">
          <div class="offset-lg-3 col-lg-9">
            <button class="btn btn-primary" type="submit" name="submitButton">
              creează
            </button>
          </div>
        </div>

      </form>
    </div>
  </div>
{/block}
