{% with m.sl_acesso.is_acesso_atual_correspondente as is_acesso_atual_correspondente %}

<input type="hidden" id="hdn_id" value="{{ id }}">

    {% include "componentes/_component_field_cad_table.tpl"
        table_id="tab_cons_unidade"
        items=[
            ["id",                           "Código"],
            ["leal_unidade$matricula",       "Matrícula"],
            ["leal_unidade$bloco",           "Bloco"],
            ["leal_unidade$nro_andar",       "Andar"],
            ["leal_unidade$nro_unidade",     "Unidade"],
            ["leal_unidade$descricao",       "Descrição"],
            ["leal_unidade$area_total",      "Área (m²)"],
            ["leal_unidade$tipo",            "Tipo"],
            ["leal_unidade$status_venda",    "Status Venda"],
            ["leal_unidade$tem_garagem",     "Garagem"],
            ["leal_unidade$tem_hobby_box",   "Hobby Box"]
        ]
    %}

    {% wire name="delete_crud_unidade" postback={unidade_crud_delete} delegate="controller_sl_empreendimento" %}
    {% wire name="edit_crud_unidade" postback={unidade_crud_edit} delegate="controller_sl_empreendimento" %}
    {% wire name="delete_crud_unidade_confirmation"
        action={sl_confirm
            text="Confirma a exclusão da Unidade selecionada?"
            title="Confirmação"
            ok="Confirmar"
            cancel="Cancelar"
            action={script
                script="executaEventExcluir('delete_crud_unidade', window.idItemDel, 'tab_cons_unidade')"
            }
        }
    %}

    {% javascript %}
        (function() {
            var _orig = window.onerror;

            function safeErrorText(value) {
                if (typeof value === 'string') return value;
                if (value && typeof value.message === 'string') return value.message;
                try { return String(value); } catch (_e) { return 'Non-serializable error'; }
            }

            window.onerror = function(message, source, lineno, colno, error) {
                var msg  = safeErrorText(message);
                var file = typeof source === 'string' ? source : '';
                var line = Number.isFinite(Number(lineno)) ? Number(lineno) : 0;
                var col  = Number.isFinite(Number(colno))  ? Number(colno)  : 0;
                var err  = error instanceof Error ? error : null;
                try { return _orig ? _orig(msg, file, line, col, err) : false; }
                catch (_handlerError) { return false; }
            };
        })();

        // Formatadores customizados
        function formatterUndefined(data) {
            return (data === null || data === undefined) ? '-' : data;
        }

        function formatterBoolean(data) {
            if (data === null || data === undefined) return '-';
            return data === true || data === 1 ? '<span class="badge badge-success">Sim</span>' : '<span class="badge badge-light">Não</span>';
        }

        function formatterTipo(data) {
            var tipos = {
                0: 'Apartamento',
                1: 'Casa',
                2: 'Lote',
                3: 'Sala Comercial',
                4: 'Barracão',
                5: 'Garagem',
                6: 'Hobby Box'
            };
            return tipos[data] || '-';
        }

        function formatterStatus(data) {
            var statusMap = {
                0: '<span class="badge badge-secondary">Cadastrado</span>',
                1: '<span class="badge badge-info">Disponível</span>',
                2: '<span class="badge badge-warning">Permutado</span>',
                3: '<span class="badge badge-success">Vendido</span>',
                4: '<span class="badge badge-danger">Indisponível</span>',
                5: '<span class="badge badge-primary">Negociação</span>',
                6: '<span class="badge badge-light">Pré-lançamento</span>',
                7: '<span class="badge badge-warning">Assinar Contrato</span>'
            };
            return statusMap[data] || '-';
        }

        $(document).ready(function(){

            var empreendimentoId = $("#hdn_id").val();

            var columns = [
                { "data": "id" },

                { 
                    "data": "leal_unidade$matricula",
                    "render": function(data){ return formatterUndefined(data); }
                },

                { 
                    "data": "leal_unidade$bloco",
                    "render": function(data){ return formatterUndefined(data); }
                },

                { 
                    "data": "leal_unidade$nro_andar",
                    "render": function(data){ return formatterUndefined(data); }
                },

                { 
                    "data": "leal_unidade$nro_unidade",
                    "render": function(data){ return formatterUndefined(data); }
                },

                { 
                    "data": "leal_unidade$descricao",
                    "render": function(data){ return formatterUndefined(data); }
                },

                { 
                    "data": "leal_unidade$area_total",
                    "render": function(data){ 
                        if (data === null || data === undefined) return '-';
                        return parseFloat(data).toFixed(2) + ' m²';
                    }
                },

                { 
                    "data": "leal_unidade$tipo",
                    "render": function(data){ return formatterTipo(data); }
                },

                { 
                    "data": "leal_unidade$status_venda",
                    "render": function(data){ return formatterStatus(data); }
                },

                { 
                    "data": "leal_unidade$tem_garagem",
                    "render": function(data){ return formatterBoolean(data); }
                },

                { 
                    "data": "leal_unidade$tem_hobby_box",
                    "render": function(data){ return formatterBoolean(data); }
                },

                {
                    "render": function(data, type, row) {
                        return '<div class="btn-group btn-group-sm" role="group">' +
                            '<button class="btn btn-sm btn-light btn-outline-secondary command-edit" ' +
                                'data-row-id="' + row.id + '" title="Editar">' +
                                '<span class="fa-solid fa-pencil-alt"></span>' +
                            '</button>' +
                            '<button class="btn btn-sm btn-light btn-outline-danger command-delete" ' +
                                'data-row-id="' + row.id + '" title="Deletar">' +
                                '<span class="fa-solid fa-times"></span>' +
                            '</button>' +
                            '</div>';
                    }
                }
            ];

            var options = {
                // Ordenação conforme SQL: bloco, andar, unidade
                "order": [[2, "asc"], [3, "asc"], [4, "asc"]],

                "ajax": function(data, callback, settings) {
                    doAjax(
                        "/api/model/sl_nova_emp/get/get_datagrid_unidade/" + empreendimentoId,
                        callback,
                        settings
                    );
                },

                "columns": columns,
                "processing": true,
                "serverSide": false,

                "columnDefs": [
                    {"visible": false, "targets": 0}, // Oculta coluna ID
                    {"orderable": false, "targets": columns.length - 1}, // Última coluna (ações)
                    {"className": "text-center fixed-column fixed-column--right", "targets": columns.length - 1}
                ],

                "drawCallback": function(){
                    criaTooltips();

                    $("#tab_cons_unidade button.command-edit")
                        .unbind("click")
                        .click(function(event){
                            event.preventDefault();
                            z_event("edit_crud_unidade", {
                                id: $(this).data("row-id")
                            });
                        });

                    $("#tab_cons_unidade button.command-delete")
                        .unbind("click")
                        .click(function(event){
                            event.preventDefault();
                            window.idItemDel = $(this).data("row-id");
                            z_event("delete_crud_unidade_confirmation", {
                                id: $(this).data("row-id")
                            });
                        });
                }
            };

            var grid = criaGridDataTables("tab_cons_unidade", options);
        });
    {% endjavascript %}

{% endwith %}