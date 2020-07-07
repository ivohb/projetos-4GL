CREATE TABLE MAN_FERRAMENTA_PROCESSO
                (
                empresa CHAR (2),
                seq_processo INTEGER,
                ferramenta CHAR (15),
                qtd_cavidades DECIMAL (10, 3),
                qtd_tempo DECIMAL (11, 7),
                texto_ferramenta VARCHAR (255)
                )


CREATE TABLE MAN_PROCESSO_ITEM
                (
                empresa CHAR (2),
                item CHAR (15),
                conteudo_grade_1 CHAR (15),
                conteudo_grade_2 CHAR (15),
                conteudo_grade_3 CHAR (15),
                conteudo_grade_4 CHAR (15),
                conteudo_grade_5 CHAR (15),
                roteiro CHAR (15),
                roteiro_alternativo DECIMAL (2, 0),
                seq_operacao INTEGER,
                prioridade INTEGER,
                operacao CHAR (5),
                centro_trabalho CHAR (5),
                arranjo CHAR (5),
                centro_custo DECIMAL (4, 0),
                qtd_tempo DECIMAL (11, 7),
                qtd_pecas_ciclo DECIMAL (12, 7),
                qtd_tempo_setup DECIMAL (11, 7),
                apontar_operacao CHAR (1),
                imprimir_operacao CHAR (1),
                operacao_final CHAR (1),
                pct_retrabalho DECIMAL (6, 3),
                validade_inicial DATE,
                validade_final DATE,
                seq_operacao_grade INTEGER,
                seq_processo INTEGER,
                seq_processo_prototipo INTEGER,
                texto_operacao VARCHAR (255),
                tip_tempo CHAR (1),
                planeja_operacao CHAR (1),
                considera_local_docum CHAR (1)
                )
