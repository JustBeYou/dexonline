Șirul <strong>{$chars|implode}</strong> conține un amestec de litere din
alfabete diferite. Vă rugăm să verificați corectitudinea.

<ul class="mt-3 mb-0">
  {foreach $chars as $c}
    <li>
      litera <strong>{$c}</strong> din alfabetul {$scriptMap[$c]}
    </li>
  {/foreach}
</ul>
