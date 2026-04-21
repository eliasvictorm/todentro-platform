package com.eventmanager.ui;

import java.time.format.DateTimeFormatter;
import java.util.List;

import com.eventmanager.dao.EventDAO;
import com.eventmanager.model.Event;

import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.ButtonType;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.ListCell;
import javafx.scene.control.ListView;
import javafx.scene.control.Separator;
import javafx.scene.control.TextField;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.Region;
import javafx.scene.layout.StackPane;
import javafx.scene.layout.VBox;

public class MainView {

    private final EventDAO dao;
    private final BorderPane root;
    private final ObservableList<Event> eventList = FXCollections.observableArrayList();
    private ListView<Event> listView;
    private TextField searchField;
    private ComboBox<String> categoryFilter;
    private Label totalLabel;

    private static final String[] CATEGORIES = {"Todas", "Conferência", "Workshop", "Show", "Esporte", "Social", "Outro"};
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");

    public MainView(EventDAO dao) {
        this.dao = dao;
        root = new BorderPane();
        root.setTop(buildTopBar());
        root.setCenter(buildMobileCenter());
        refreshList();
    }

    public BorderPane getRoot() { return root; }

    // ── Top Bar ──────────────────────────────────────────────────────────────

    private HBox buildTopBar() {
        HBox bar = new HBox();
        bar.getStyleClass().add("top-bar");
        bar.setAlignment(Pos.CENTER_LEFT);
        bar.setSpacing(12);
        bar.setPadding(new Insets(14, 20, 14, 20));

        Label title = new Label("📅 Gerenciador de Eventos");
        title.getStyleClass().add("app-title");

        Region spacer = new Region();
        HBox.setHgrow(spacer, Priority.ALWAYS);

        Button newBtn = new Button("+ Novo Evento");
        newBtn.getStyleClass().add("btn-primary");
        newBtn.setOnAction(e -> openEventForm(null));

        bar.getChildren().addAll(title, spacer, newBtn);
        return bar;
    }

    // ── Sidebar ──────────────────────────────────────────────────────────────

    private VBox buildSidebar() {
        VBox sidebar = new VBox(8);
        sidebar.getStyleClass().add("sidebar");
        sidebar.setPadding(new Insets(16));
        sidebar.setPrefWidth(220);

        Label searchLabel = new Label("Buscar");
        searchLabel.getStyleClass().add("section-label");
        searchField = new TextField();
        searchField.setPromptText("Nome, local...");
        searchField.textProperty().addListener((o, ov, nv) -> refreshList());

        Label catLabel = new Label("Categoria");
        catLabel.getStyleClass().add("section-label");
        categoryFilter = new ComboBox<>(FXCollections.observableArrayList(CATEGORIES));
        categoryFilter.setValue("Todas");
        categoryFilter.setMaxWidth(Double.MAX_VALUE);
        categoryFilter.setOnAction(e -> refreshList());

        totalLabel = new Label();
        totalLabel.getStyleClass().add("total-label");

        Button clearBtn = new Button("Limpar filtros");
        clearBtn.getStyleClass().add("btn-ghost");
        clearBtn.setMaxWidth(Double.MAX_VALUE);
        clearBtn.setOnAction(e -> {
            searchField.clear();
            categoryFilter.setValue("Todas");
        });

        sidebar.getChildren().addAll(searchLabel, searchField, catLabel, categoryFilter,
                new Separator(), totalLabel, clearBtn);
        return sidebar;
    }

    // ── Center ─ Mobile Layout ──────────────────────────────────────────────

    private VBox buildMobileCenter() {
        VBox container = new VBox(12);
        container.setPadding(new Insets(12, 12, 12, 12));
        container.setStyle("-fx-fill-height: true;");

        // Search field
        searchField = new TextField();
        searchField.setPromptText("🔍 Buscar evento...");
        searchField.setPrefHeight(40);
        searchField.setStyle("-fx-font-size: 13px; -fx-padding: 8;");
        searchField.textProperty().addListener((o, ov, nv) -> refreshList());

        // Category filter
        HBox filterBox = new HBox(8);
        filterBox.setAlignment(Pos.CENTER_LEFT);
        Label catLabel = new Label("Categoria:");
        categoryFilter = new ComboBox<>(FXCollections.observableArrayList(CATEGORIES));
        categoryFilter.setValue("Todas");
        categoryFilter.setMaxWidth(Double.MAX_VALUE);
        categoryFilter.setPrefHeight(36);
        categoryFilter.setStyle("-fx-font-size: 12px;");
        categoryFilter.setOnAction(e -> refreshList());
        HBox.setHgrow(categoryFilter, Priority.ALWAYS);
        filterBox.getChildren().addAll(catLabel, categoryFilter);

        // Total label
        totalLabel = new Label();
        totalLabel.getStyleClass().add("total-label");
        totalLabel.setStyle("-fx-font-size: 12px; -fx-text-fill: #b50027; -fx-font-weight: bold;");

        // Event list
        listView = new ListView<>(eventList);
        listView.getStyleClass().add("event-list");
        listView.setCellFactory(lv -> new EventCell());
        VBox.setVgrow(listView, Priority.ALWAYS);

        container.getChildren().addAll(searchField, filterBox, totalLabel, listView);
        return container;
    }

    // ── Center ─ Event List (legacy) ─────────────────────────────────────────

    private StackPane buildCenter() {
        listView = new ListView<>(eventList);
        listView.getStyleClass().add("event-list");
        listView.setCellFactory(lv -> new EventCell());

        StackPane center = new StackPane(listView);
        center.setPadding(new Insets(16));
        return center;
    }

    private class EventCell extends ListCell<Event> {
        @Override
        protected void updateItem(Event event, boolean empty) {
            super.updateItem(event, empty);
            if (empty || event == null) {
                setGraphic(null);
                return;
            }

            VBox card = new VBox(8);
            card.getStyleClass().add("event-card");
            card.setPadding(new Insets(12));
            card.setStyle("-fx-border-radius: 16; -fx-background-radius: 16;");

            // Header: name + badge
            HBox header = new HBox(8);
            header.setAlignment(Pos.CENTER_LEFT);
            
            Label nameLabel = new Label(event.getName());
            nameLabel.getStyleClass().add("event-name");
            nameLabel.setStyle("-fx-font-size: 15px; -fx-font-weight: bold;");
            nameLabel.setWrapText(true);
            HBox.setHgrow(nameLabel, Priority.ALWAYS);

            Label catBadge = new Label(event.getCategory() != null ? event.getCategory() : "");
            catBadge.getStyleClass().addAll("badge", "badge-" + categoryIndex(event.getCategory()));
            catBadge.setStyle("-fx-font-size: 11px; -fx-padding: 4 8;");

            header.getChildren().addAll(nameLabel, catBadge);

            // Meta info (data, hora, local)
            VBox meta = new VBox(4);
            meta.setStyle("-fx-font-size: 12px; -fx-text-fill: #333;");

            // Descrição se existir
            if (event.getDescription() != null && !event.getDescription().trim().isEmpty()) {
                Label descLabel = new Label(event.getDescription());
                descLabel.setStyle("-fx-font-size: 11px; -fx-text-fill: #666; -fx-wrap-text: true;");
                descLabel.setWrapText(true);
                meta.getChildren().add(descLabel);
            }

            Label dateLabel = new Label("📅 " + (event.getDate() != null ? event.getDate().format(DATE_FMT) : "—"));
            dateLabel.setStyle("-fx-text-fill: #333;");
            Label timeLabel = new Label("🕐 " + (event.getTime() != null ? event.getTime().format(TIME_FMT) : "—"));
            timeLabel.setStyle("-fx-text-fill: #333;");
            Label locLabel  = new Label("📍 " + (event.getLocation() != null ? event.getLocation() : "—"));
            locLabel.setWrapText(true);
            locLabel.setStyle("-fx-text-fill: #333;");

            meta.getChildren().addAll(dateLabel, timeLabel, locLabel);

            // Participants info
            int participants = event.getParticipants().size();
            int max = event.getMaxParticipants();
            long confirmados = event.getParticipants().stream()
                    .filter(p -> "Confirmado".equals(p.getStatus()))
                    .count();

            long pendentes = event.getParticipants().stream()
                    .filter(p -> "Pendente".equals(p.getStatus()))
                    .count();

            // Linha principal de vagas
            Label slots = new Label("👥 " + participants + "/" + max + " participantes");
            slots.setStyle("-fx-font-size: 12px;");
            if (!event.hasAvailableSlots()) 
                slots.setStyle("-fx-font-size: 12px; -fx-text-fill: #ff6b6b;");

            // 🆕 Linha de resumo dos status
            Label statusSummary = new Label(
                "✅ " + confirmados + " confirmados  🕐 " + pendentes + " pendentes"
            );
            statusSummary.setStyle("-fx-font-size: 11px; -fx-text-fill: #555;");
            slots.setStyle("-fx-font-size: 12px;");
            if (!event.hasAvailableSlots()) slots.setStyle("-fx-font-size: 12px; -fx-text-fill: #ff6b6b;");

            // Action buttons
            VBox actions = new VBox(6);
            actions.setStyle("-fx-spacing: 6;");
            
            Button editBtn = new Button("✏️ Editar");
            editBtn.getStyleClass().add("btn-mobile");
            editBtn.setMaxWidth(Double.MAX_VALUE);
            editBtn.setPrefHeight(36);
            editBtn.setStyle("-fx-font-size: 12px;");
            editBtn.setOnAction(e -> openEventForm(event));

            Button participantsBtn = new Button("👥 Participantes");
            participantsBtn.getStyleClass().add("btn-mobile");
            participantsBtn.setMaxWidth(Double.MAX_VALUE);
            participantsBtn.setPrefHeight(36);
            participantsBtn.setStyle("-fx-font-size: 12px;");
            participantsBtn.setOnAction(e -> openParticipantsView(event));

            Button deleteBtn = new Button("🗑️ Excluir");
            deleteBtn.getStyleClass().addAll("btn-mobile", "btn-danger");
            deleteBtn.setMaxWidth(Double.MAX_VALUE);
            deleteBtn.setPrefHeight(36);
            deleteBtn.setStyle("-fx-font-size: 12px;");
            deleteBtn.setOnAction(e -> confirmDelete(event));

            actions.getChildren().addAll(editBtn, participantsBtn, deleteBtn);

            card.getChildren().addAll(header, meta, slots, statusSummary, actions);
            setGraphic(card);
        }

        private int categoryIndex(String cat) {
            if (cat == null) return 0;
            return switch (cat) {
                case "Conferência" -> 1;
                case "Workshop"    -> 2;
                case "Show"        -> 3;
                case "Esporte"     -> 4;
                case "Social"      -> 5;
                default            -> 0;
            };
        }
    }

    // ── Actions ──────────────────────────────────────────────────────────────

    private void openEventForm(Event event) {
        EventFormDialog dialog = new EventFormDialog(event);
        dialog.showAndWait().ifPresent(result -> {
            dao.save(result);
            refreshList();
        });
    }

    private void openParticipantsView(Event event) {
        ParticipantsDialog dialog = new ParticipantsDialog(event, dao);
        dialog.showAndWait();
        refreshList();
    }

    private void confirmDelete(Event event) {
        Alert alert = new Alert(Alert.AlertType.CONFIRMATION);
        alert.setTitle("Confirmar exclusão");
        alert.setHeaderText("Excluir evento: " + event.getName() + "?");
        alert.setContentText("Esta ação não pode ser desfeita. Os " +
                event.getParticipants().size() + " participante(s) também serão removidos.");
        alert.showAndWait().ifPresent(btn -> {
            if (btn == ButtonType.OK) {
                dao.delete(event.getId());
                refreshList();
            }
        });
    }

    // ── Refresh ───────────────────────────────────────────────────────────────

    private void refreshList() {
        String query = searchField != null ? searchField.getText() : "";
        String cat   = categoryFilter != null ? categoryFilter.getValue() : "Todas";
        List<Event> results = dao.search(query, cat);
        eventList.setAll(results);
        if (totalLabel != null) {
            totalLabel.setText(results.size() + " evento(s) encontrado(s)");
        }
    }
}
