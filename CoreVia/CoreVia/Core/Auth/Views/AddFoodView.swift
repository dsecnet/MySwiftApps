

import SwiftUI

struct AddFoodView: View {

    @Environment(\.dismiss) var dismiss
    @StateObject private var foodManager = FoodManager.shared
    @StateObject private var foodImageManager = FoodImageManager.shared

    @State private var foodName: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fats: String = ""
    @State private var selectedMealType: MealType = .breakfast
    @State private var notes: String = ""
    @State private var showSuccessAlert: Bool = false

    @State private var showCamera = false
    @State private var capturedImage: UIImage? = nil
    @State private var isAnalyzing = false
    @State private var analysisComplete = false

    @ObservedObject private var loc = LocalizationManager.shared
    @ObservedObject private var settingsManager = SettingsManager.shared
    @State private var showPremium = false

    private var mockFoodResults: [(name: String, calories: Int, protein: Double, carbs: Double, fats: Double)] {
        [
            (loc.localized("food_mock_pilaf"), 450, 28, 55, 12),
            (loc.localized("food_mock_dovga"), 180, 8, 22, 6),
            (loc.localized("food_mock_wrap"), 380, 18, 42, 14),
            (loc.localized("food_mock_salad"), 120, 4, 15, 5),
            (loc.localized("food_mock_kebab"), 320, 35, 5, 18),
            (loc.localized("food_mock_omelette"), 280, 18, 4, 22),
            (loc.localized("food_mock_soup"), 220, 12, 30, 6),
            (loc.localized("food_mock_rice"), 350, 8, 65, 5),
            (loc.localized("food_mock_steak"), 400, 42, 0, 24),
            (loc.localized("food_mock_pasta"), 380, 14, 58, 10)
        ]
    }

    var quickAddItems: [QuickAddFood] {
        [
            QuickAddFood(name: loc.localized("food_quick_egg"), calories: 78, protein: 6, carbs: 0.6, fats: 5, icon: "🥚"),
            QuickAddFood(name: loc.localized("food_quick_banana"), calories: 105, protein: 1.3, carbs: 27, fats: 0.4, icon: "🍌"),
            QuickAddFood(name: loc.localized("food_quick_chicken"), calories: 165, protein: 31, carbs: 0, fats: 3.6, icon: "🍗"),
            QuickAddFood(name: loc.localized("food_quick_apple"), calories: 95, protein: 0.5, carbs: 25, fats: 0.3, icon: "🍎"),
            QuickAddFood(name: loc.localized("food_quick_oatmeal"), calories: 389, protein: 17, carbs: 66, fats: 7, icon: "🥣"),
            QuickAddFood(name: loc.localized("food_quick_juice"), calories: 117, protein: 0.3, carbs: 29, fats: 0.3, icon: "🧃")
        ]
    }

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle(loc.localized("food_add_title"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(loc.localized("common_close")) {
                            dismiss()
                        }
                        .foregroundColor(AppTheme.Colors.accent)
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(loc.localized("common_save")) {
                            saveFood()
                        }
                        .foregroundColor(AppTheme.Colors.accent)
                        .fontWeight(.semibold)
                        .disabled(!isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.5)
                    }
                }
                .alert(loc.localized("common_success"), isPresented: $showSuccessAlert) {
                    Button("OK") {
                        dismiss()
                    }
                } message: {
                    Text(loc.localized("food_added"))
                }
                .sheet(isPresented: $showCamera) {
                    CameraPicker(image: $capturedImage)
                }
                .sheet(isPresented: $showPremium) {
                    PremiumView()
                }
                .onChange(of: capturedImage) { newImage in
                    if newImage != nil {
                        startMockAnalysis()
                    }
                }
                .onChange(of: calories) { val in
                    calories = val.filter { $0.isNumber }
                    if let n = Int(calories), n > 10000 { calories = "10000" }
                }
                .onChange(of: protein) { val in
                    protein = val.filter { $0.isNumber || $0 == "." }
                    if let n = Double(protein), n > 1000 { protein = "1000" }
                }
                .onChange(of: carbs) { val in
                    carbs = val.filter { $0.isNumber || $0 == "." }
                    if let n = Double(carbs), n > 1000 { carbs = "1000" }
                }
                .onChange(of: fats) { val in
                    fats = val.filter { $0.isNumber || $0 == "." }
                    if let n = Double(fats), n > 1000 { fats = "1000" }
                }
                .onChange(of: notes) { val in
                    if val.count > 1000 { notes = String(val.prefix(1000)) }
                }
        }
    }

    // MARK: - Content View
    private var contentView: some View {
        ZStack {
            AppTheme.Colors.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    cameraSection
                    quickAddSection
                    mealTypeSelector
                    mainForm
                    macrosSection
                    notesSection
                }
                .padding()
            }
        }
    }

    // MARK: - Camera Section
    private var cameraSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(loc.localized("food_take_photo"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                if !settingsManager.isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10))
                        Text("Premium")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.Colors.accent, AppTheme.Colors.accentDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(8)
                }
            }

            if settingsManager.isPremium {
                premiumCameraContent
            } else {
                lockedCameraContent
            }
        }
    }

    // MARK: - Premium Camera Content (aciq)
    private var premiumCameraContent: some View {
        Group {
            if let image = capturedImage {
                VStack(spacing: 16) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    if isAnalyzing {
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.Colors.accent))
                                .scaleEffect(1.2)

                            Text(loc.localized("food_analyzing"))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.secondaryBackground)
                        .cornerRadius(12)
                    } else if analysisComplete {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.Colors.success)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(loc.localized("food_analysis_done"))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.primaryText)

                                Text(loc.localized("food_results_filled"))
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.Colors.secondaryText)
                            }

                            Spacer()
                        }
                        .padding()
                        .background(AppTheme.Colors.success.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.Colors.success.opacity(0.3), lineWidth: 1)
                        )
                    }

                    Button {
                        capturedImage = nil
                        analysisComplete = false
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.rotate")
                                .font(.system(size: 14))
                            Text(loc.localized("food_retake"))
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.Colors.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppTheme.Colors.accent.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            } else {
                Button {
                    showCamera = true
                } label: {
                    VStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.Colors.accent.opacity(0.2), AppTheme.Colors.accent.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 70, height: 70)

                            Image(systemName: "camera.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppTheme.Colors.accent)
                        }

                        VStack(spacing: 4) {
                            Text(loc.localized("food_take_photo_desc"))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.primaryText)

                            Text(loc.localized("food_ai_calc"))
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.Colors.secondaryText)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(AppTheme.Colors.secondaryBackground)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppTheme.Colors.accent.opacity(0.3), style: StrokeStyle(lineWidth: 1.5, dash: [8, 6]))
                    )
                }
            }
        }
    }

    // MARK: - Locked Camera Content (premium lazimdir)
    private var lockedCameraContent: some View {
        Button {
            showPremium = true
        } label: {
            ZStack {
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 70, height: 70)

                        Image(systemName: "camera.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray.opacity(0.4))
                    }

                    VStack(spacing: 4) {
                        Text(loc.localized("food_take_photo_desc"))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.tertiaryText)

                        Text(loc.localized("food_ai_calc"))
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.tertiaryText)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .blur(radius: 1)

                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.Colors.accent, AppTheme.Colors.accentDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)

                        Image(systemName: "lock.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                    }

                    Text(loc.localized("food_ai_calorie_analysis"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.Colors.primaryText)

                    Text(loc.localized("food_unlock_premium"))
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.Colors.secondaryText)

                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 13))
                        Text(loc.localized("food_go_premium"))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.Colors.accent, AppTheme.Colors.accentDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppTheme.Colors.accent.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Quick Add Section
    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("food_quick_add"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(quickAddItems) { item in
                        QuickAddButton(item: item) {
                            fillForm(with: item)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Meal Type Selector
    private var mealTypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("food_meal_type"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 12) {
                ForEach(MealType.allCases, id: \.self) { type in
                    MealTypeButton(
                        type: type,
                        isSelected: selectedMealType == type
                    ) {
                        withAnimation(.spring()) {
                            selectedMealType = type
                        }
                    }
                }
            }
        }
    }

    // MARK: - Main Form
    private var mainForm: some View {
        VStack(spacing: 16) {
            FoodInputField(
                label: loc.localized("food_name"),
                icon: "fork.knife",
                placeholder: loc.localized("food_name_placeholder"),
                text: $foodName
            )

            FoodInputField(
                label: loc.localized("food_calories"),
                icon: "flame.fill",
                placeholder: loc.localized("food_calories_placeholder"),
                text: $calories,
                keyboardType: .numberPad
            )
        }
    }

    // MARK: - Macros Section
    private var macrosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(loc.localized("food_macros"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.primaryText)

                Spacer()

                Text(loc.localized("common_gram"))
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.Colors.secondaryText)
            }

            HStack(spacing: 12) {
                MacroInputField(
                    label: loc.localized("food_protein"),
                    icon: "💪",
                    color: AppTheme.Colors.accent,
                    text: $protein
                )

                MacroInputField(
                    label: loc.localized("food_carbs"),
                    icon: "🍞",
                    color: AppTheme.Colors.accentDark,
                    text: $carbs
                )

                MacroInputField(
                    label: loc.localized("food_fats"),
                    icon: "🥑",
                    color: AppTheme.Colors.accent,
                    text: $fats
                )
            }
        }
    }

    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(loc.localized("workout_notes"))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            ZStack(alignment: .topLeading) {
                if notes.isEmpty {
                    Text(loc.localized("food_notes_placeholder"))
                        .foregroundColor(AppTheme.Colors.tertiaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                }

                TextEditor(text: $notes)
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .scrollContentBackground(.hidden)
                    .frame(height: 80)
                    .padding(8)
            }
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
        }
    }

    // MARK: - Computed Properties
    private var isFormValid: Bool {
        let trimmed = foodName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed.count <= 200 else { return false }
        guard let cal = Int(calories), cal >= 0, cal <= 10000 else { return false }
        if let p = Double(protein), (p < 0 || p > 1000) { return false }
        if let c = Double(carbs), (c < 0 || c > 1000) { return false }
        if let f = Double(fats), (f < 0 || f > 1000) { return false }
        return true
    }

    // MARK: - Actions
    private func saveFood() {
        guard isFormValid else { return }

        let entryId = UUID().uuidString
        let hasPhoto = capturedImage != nil

        let entry = FoodEntry(
            id: entryId,
            name: foodName,
            calories: Int(calories) ?? 0,
            protein: Double(protein),
            carbs: Double(carbs),
            fats: Double(fats),
            mealType: selectedMealType,
            notes: notes.isEmpty ? nil : notes,
            hasImage: hasPhoto
        )

        if let image = capturedImage {
            foodImageManager.saveImage(image, forEntryId: entryId)
        }

        foodManager.addEntry(entry)

        withAnimation {
            showSuccessAlert = true
        }
    }

    private func fillForm(with item: QuickAddFood) {
        foodName = item.name
        calories = "\(item.calories)"
        protein = "\(Int(item.protein))"
        carbs = "\(Int(item.carbs))"
        fats = "\(Int(item.fats))"
    }

    // MARK: - Mock Analiz
    private func startMockAnalysis() {
        isAnalyzing = true
        analysisComplete = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let randomResult = mockFoodResults.randomElement()!
            foodName = randomResult.name
            calories = "\(randomResult.calories)"
            protein = "\(Int(randomResult.protein))"
            carbs = "\(Int(randomResult.carbs))"
            fats = "\(Int(randomResult.fats))"

            withAnimation {
                isAnalyzing = false
                analysisComplete = true
            }
        }
    }
}

// MARK: - Quick Add Food Model
struct QuickAddFood: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fats: Double
    let icon: String
}

// MARK: - Components

struct QuickAddButton: View {
    let item: QuickAddFood
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(item.icon)
                    .font(.system(size: 30))

                Text(item.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 30)

                Text("\(item.calories) kcal")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.accent)
            }
            .frame(width: 100)
            .padding(.vertical, 12)
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.Colors.separator, lineWidth: 1)
            )
        }
    }
}

struct MealTypeButton: View {
    let type: MealType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.system(size: 20))

                Text(type.localizedName)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : AppTheme.Colors.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected ?
                type.color :
                AppTheme.Colors.secondaryBackground
            )
            .cornerRadius(12)
        }
    }
}

struct FoodInputField: View {
    let label: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.primaryText)

            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(AppTheme.Colors.accent)
                    .frame(width: 20)

                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(AppTheme.Colors.tertiaryText))
                    .foregroundColor(AppTheme.Colors.primaryText)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(AppTheme.Colors.secondaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        text.isEmpty ? AppTheme.Colors.separator : AppTheme.Colors.accent.opacity(0.5),
                        lineWidth: 1
                    )
            )
        }
    }
}

struct MacroInputField: View {
    let label: String
    let icon: String
    let color: Color
    @Binding var text: String

    var body: some View {
        VStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 24))

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.Colors.secondaryText)

            TextField("0", text: $text)
                .foregroundColor(AppTheme.Colors.primaryText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .padding(8)
                .background(AppTheme.Colors.secondaryBackground)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(text.isEmpty ? AppTheme.Colors.separator : color, lineWidth: 1)
                )
        }
    }
}

// #Preview { // iOS 17+ only
//     AddFoodView()
// }
