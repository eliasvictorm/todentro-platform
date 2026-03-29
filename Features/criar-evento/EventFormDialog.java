package com.eventmanager.ui;

import com.eventmanager.model.Event;
import javafx.geometry.Insets;
import javafx.scene.control.*;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;

public class EventFormDialog extends Dialog<Event> {

    private final TextField nameField       = new TextField();
    private final TextArea  descField       = new TextArea();
    private final DatePicker datePicker     = new DatePicker();
    private final TextField timeField       = new TextField();
    private final TextField locationField   = new TextField();
    private final Spinner<Integer> maxSpinner = new Spinner<>(1, 9999, 50);
    private final ComboBox<String> catCombo;

    private static final String[] CATEGORIES = {"Conferência", "Workshop", "Show", "Esporte", "Social", "Outro"};

    public EventFormDialog(Event existing) {
        setTitle(existing == null ? "Novo Evento" : "Editar Evento");
        setHeaderText(existing == null ? "Preencha os dados do evento" : "Atualize os dados do evento");

        catCombo = new ComboBox<>();
        catCombo.getItems().addAll(CATEGORIES);
        catCombo.setValue(CATEGORIES[0]);

        ButtonType saveBtn = new ButtonType("Salvar", ButtonBar.ButtonData.OK_DONE);
        getDialogPane().getButtonTypes().addAll(saveBtn, ButtonType.CANCEL);

        getDialogPane().setContent(buildForm());
        getDialogPane().setPrefWidth(480);

        if (existing != null) populate(existing);

        setResultConverter(btn -> {
            if (btn == saveBtn) return buildEvent(existing);
            return null;
        });

        getDialogPane().lookupButton(saveBtn).addEventFilter(javafx.event.ActionEvent.ACTION, e -> {
            String err = validate();
            if (err != null) {
                e.consume();
                showError(err);
            }
        });
    }

    private VBox buildForm() {
        GridPane grid = new GridPane();
        grid.setHgap(12);
        grid.setVgap(10);
        grid.setPadding(new Insets(16, 0, 8, 0));

        nameField.setPromptText("Nome do evento");
        descField.setPromptText("Descrição (opcional)");
        descField.setPrefRowCount(3);
        descField.setWrapText(true);
        timeField.setPromptText("HH:mm (ex: 14:30)");
        locationField.setPromptText("Local ou endereço");
        maxSpinner.setEditable(true);
        maxSpinner.setPrefWidth(100);
        datePicker.setPromptText("dd/mm/aaaa");

        addRow(grid, 0, "Nome *", nameField);
        addRow(grid, 1, "Descrição", descField);
        addRow(grid, 2, "Data *", datePicker);
        addRow(grid, 3, "Horário *", timeField);
        addRow(grid, 4, "Local *", locationField);
        addRow(grid, 5, "Máx. participantes", maxSpinner);
        addRow(grid, 6, "Categoria", catCombo);

        GridPane.setHgrow(nameField, Priority.ALWAYS);
        GridPane.setHgrow(descField, Priority.ALWAYS);
        GridPane.setHgrow(locationField, Priority.ALWAYS);
        catCombo.setMaxWidth(Double.MAX_VALUE);
        GridPane.setHgrow(catCombo, Priority.ALWAYS);

        VBox box = new VBox(grid);
        box.setPadding(new Insets(0, 4, 0, 4));
        return box;
    }

    private void addRow(GridPane grid, int row, String label, javafx.scene.Node field) {
        Label lbl = new Label(label);
        lbl.setMinWidth(130);
        grid.add(lbl, 0, row);
        grid.add(field, 1, row);
    }

    private void populate(Event e) {
        nameField.setText(e.getName());
        descField.setText(e.getDescription() != null ? e.getDescription() : "");
        datePicker.setValue(e.getDate());
        timeField.setText(e.getTime() != null ? e.getTime().toString() : "");
        locationField.setText(e.getLocation());
        maxSpinner.getValueFactory().setValue(e.getMaxParticipants());
        if (e.getCategory() != null) catCombo.setValue(e.getCategory());
    }

    private Event buildEvent(Event existing) {
        Event ev = (existing != null) ? existing : new Event();
        ev.setName(nameField.getText().trim());
        ev.setDescription(descField.getText().trim());
        ev.setDate(datePicker.getValue());
        try { ev.setTime(LocalTime.parse(timeField.getText().trim())); }
        catch (DateTimeParseException ignored) {}
        ev.setLocation(locationField.getText().trim());
        ev.setMaxParticipants(maxSpinner.getValue());
        ev.setCategory(catCombo.getValue());
        return ev;
    }

    private String validate() {
        if (nameField.getText().isBlank()) return "O nome do evento é obrigatório.";
        if (datePicker.getValue() == null) return "Informe a data do evento.";
        if (timeField.getText().isBlank()) return "Informe o horário do evento.";
        try { LocalTime.parse(timeField.getText().trim()); }
        catch (DateTimeParseException e) { return "Horário inválido. Use o formato HH:mm (ex: 14:30)."; }
        if (locationField.getText().isBlank()) return "Informe o local do evento.";
        return null;
    }

    private void showError(String msg) {
        Alert alert = new Alert(Alert.AlertType.WARNING);
        alert.setTitle("Dados inválidos");
        alert.setHeaderText(null);
        alert.setContentText(msg);
        alert.showAndWait();
    }
}
