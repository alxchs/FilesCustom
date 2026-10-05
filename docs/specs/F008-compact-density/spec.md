# Especificação F008: Densidade Ultra-Compacta OneCommander

## Objetivo
Implementar controle de densidade global de interface no Files App inspirado no OneCommander, permitindo modos de densidade Normal, Compacto e Ultra-compacto para maximizar o número de itens visíveis na tela simultaneamente.

## Escopo
- Adição da configuração `AppDensity` em `AppearanceSettingsService`.
- Atualização do cálculo de alturas em `LayoutSizeKindHelper` para Details, List e Columns.
- Atualização dinâmica da altura dos itens da barra lateral (Sidebar) via recurso de tema XAML.
- Atualização dinâmica da página de detalhes (`DetailsLayoutPage`) mediante alteração de configuração.
- Exposição do controle na página Configurações > Aparência com localização em inglês e português.

## Critérios de Aceitação
1. A seleção de densidade deve persistir entre reinicializações.
2. A troca em Configurações > Aparência deve surtir efeito imediato na lista de arquivos e na barra lateral.
3. No modo Ultra-compacto, a altura de cada linha em Detalhes deve ser de 24px (contra 36px do modo normal).
4. O build em Release x64 deve manter zero warnings e zero errors.
