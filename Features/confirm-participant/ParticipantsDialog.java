package com.eventmanager.ui;

import com.eventmanager.dao.EventDAO;
import com.eventmanager.model.Event;
import com.eventmanager.model.Participant;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.geometry.Insets;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.ButtonType;
import javafx.scene.control.Dialog;
import javafx.scene.control.Label;
import javafx.scene.control.ProgressBar;
import javafx.scene.control.TableCell;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

public class ParticipantsDialog extends Dialog<Void> {

    private final Event event;
    private final EventDAO dao;
    private final ObservableList<Participant> participantList = FXCollections.observableArrayList();
    private TableView<Participant> table;
    private Label countLabel;

    public ParticipantsDialog(Event event, EventDAO dao) {
        this.event = event;
        this.dao = dao;

        setTitle("Participantes — " + event.getName());
        setHeaderText(null);

        getDialogPane().setContent(buildContent());
        getDialogPane().getButtonTypes().add(ButtonType.CLOSE);
        getDialogPane().setPrefSize(640, 480);

        refresh();
    }

    private VBox buildContent() {
        // Count / capacity header
        countLabel = new Label();
        countLabel.getStyleClass().add("section-label");

        ProgressBar progress = new ProgressBar();
        progress.setMaxWidth(Double.MAX_VALUE);

        // Table
        table = new TableView<>(participantList);
        table.setColumnResizePolicy(TableView.CONSTRAINED_RESIZE_POLICY_ALL_COLUMNS);
        VBox.setVgrow(table, Priority.ALWAYS);

        TableColumn<Participant, String> nameCol = new TableColumn<>("Nome");
        nameCol.setCellValueFactory(new PropertyValueFactory<>("name"));

        TableColumn<Participant, String> emailCol = new TableColumn<>("E-mail");
        emailCol.setCellValueFactory(new PropertyValueFactory<>("email"));

        TableColumn<Participant, String> phoneCol = new TableColumn<>("Telefone");
        phoneCol.setCellValueFactory(new PropertyValueFactory<>("phone"));

        TableColumn<Participant, String> statusCol = new TableColumn<>("Status");
        statusCol.setCellValueFactory(new PropertyValueFactory<>("status"));
        statusCol.setCellFactory(col -> new TableCell<>() {
            @Override protected void updateItem(String status, boolean empty) {
                super.updateItem(status, empty);
                if (empty || status == null) {
                    setGraphic(null);
                } else {
                    Label badge = new Label(status);
                    badge.setPadding(new Insets(4, 10, 4, 10));
                    badge.setStyle(getStatusStyle(status));
                    setGraphic(badge);
                }
            }
        });

        TableColumn<Participant, Void> actionCol = new TableColumn<>("Ações");
        actionCol.setMinWidth(250);
        actionCol.setCellFactory(col -> new TableCell<>() {
            @Override protected void updateItem(Void v, boolean empty) {
                super.updateItem(v, empty);
                if (empty) {
                    setGraphic(null);
                } else {
                    Participant p = getTableView().getItems().get(getIndex());
                    HBox buttons = new HBox(4);
                    buttons.setStyle("-fx-alignment: center-left;");

                    Button confirmBtn = new Button("✅ Confirmar");
                    confirmBtn.getStyleClass().add("btn-mobile");
                    confirmBtn.setStyle("-fx-background-color: #27ae60; -fx-text-fill: white; -fx-font-size: 11px; -fx-padding: 4 10;");
                    confirmBtn.setDisable(p.getStatus().equals("Confirmado"));
                    confirmBtn.setOnAction(e -> {
                        dao.updateParticipantStatus(p.getId(), "Confirmado");
                        p.setStatus("Confirmado");
                        refresh();
                    });

                    Button cancelBtn = new Button("❌ Cancelar");
                    cancelBtn.getStyleClass().add("btn-mobile");
                    cancelBtn.setStyle("-fx-background-color: #e74c3c; -fx-text-fill: white; -fx-font-size: 11px; -fx-padding: 4 10;");
                    cancelBtn.setDisable(p.getStatus().equals("Cancelado"));
                    cancelBtn.setOnAction(e -> {
                        dao.updateParticipantStatus(p.getId(), "Cancelado");
                        p.setStatus("Cancelado");
                        refresh();
                    });

                    Button removeBtn = new Button("🗑️ Remover");
                    removeBtn.getStyleClass().add("btn-mobile");
                    removeBtn.setStyle("-fx-background-color: #c0392b; -fx-text-fill: white; -fx-font-size: 11px; -fx-padding: 4 10;");
                    removeBtn.setOnAction(e -> {
                        dao.removeParticipant(event.getId(), p.getId());
                        event.getParticipants().remove(p);
                        refresh();
                    });

                    buttons.getChildren().addAll(confirmBtn, cancelBtn, removeBtn);
                    setGraphic(buttons);
                }
            }
        });

        table.getColumns().addAll(nameCol, emailCol, phoneCol, statusCol, actionCol);

        // Add participant form
        Label addLabel = new Label("Adicionar participante");
        addLabel.getStyleClass().add("section-label");

        GridPane form = new GridPane();
        form.setHgap(8);
        form.setVgap(6);

        TextField nameField  = new TextField(); nameField.setPromptText("Nome *");
        TextField emailField = new TextField(); emailField.setPromptText("E-mail *");
        TextField phoneField = new TextField(); phoneField.setPromptText("Telefone");

        Button addBtn = new Button("Adicionar");
        addBtn.getStyleClass().add("btn-primary");

        form.add(nameField,  0, 0); GridPane.setHgrow(nameField, Priority.ALWAYS);
        form.add(emailField, 1, 0); GridPane.setHgrow(emailField, Priority.ALWAYS);
        form.add(phoneField, 2, 0); GridPane.setHgrow(phoneField, Priority.ALWAYS);
        form.add(addBtn,     3, 0);

        addBtn.setOnAction(e -> {
            String name  = nameField.getText().trim();
            String email = emailField.getText().trim();
            String phone = phoneField.getText().trim();
            if (name.isEmpty() || email.isEmpty()) {
                showError("Nome e e-mail são obrigatórios.");
                return;
            }
            if (!event.hasAvailableSlots()) {
                showError("Evento lotado! Não há vagas disponíveis.");
                return;
            }
            Participant p = new Participant(name, email, phone, event.getId());
            dao.addParticipant(event.getId(), p);
            nameField.clear(); emailField.clear(); phoneField.clear();
            refresh();
        });

            VBox content = new VBox(10, countLabel, table, addLabel, form);
            content.setPadding(new Insets(12, 4, 4, 4));
            return content;
        }

    // 🆕 Método auxiliar que retorna o CSS certo para cada status
    private String getStatusStyle(String status) {
            return switch (status) {
                case "Confirmado" -> "-fx-background-color: #e8f5e9; -fx-text-fill: #2e7d32; " +
                                    "-fx-background-radius: 12; -fx-font-weight: bold;";
                case "Cancelado"  -> "-fx-background-color: #ffebee; -fx-text-fill: #c62828; " +
                                    "-fx-background-radius: 12; -fx-font-weight: bold;";
                default           -> "-fx-background-color: #fff3e0; -fx-text-fill: #e65100; " +
                                    "-fx-background-radius: 12; -fx-font-weight: bold;";
            };

        }

    private void refresh() {
        participantList.setAll(event.getParticipants());
        int current = event.getParticipants().size();
        int max     = event.getMaxParticipants();
        countLabel.setText(current + " / " + max + " participantes  •  " +
                event.getAvailableSlots() + " vagas disponíveis");
    }

    private void showError(String msg) {
        Alert alert = new Alert(Alert.AlertType.WARNING);
        alert.setTitle("Atenção");
        alert.setHeaderText(null);
        alert.setContentText(msg);
        alert.showAndWait();
    }
}
