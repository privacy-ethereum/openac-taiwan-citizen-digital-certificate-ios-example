//
//  ContentView.swift
//  OpenACExampleApp
//
//  Created by 鄭雅文 on 2026/4/5.
//

import SwiftUI

// MARK: - 測試驗證端 Color Palette

private extension Color {
    static let tvdBackground = Color(red: 23/255,  green: 23/255,  blue: 23/255)
    static let tvdSurface    = Color(red: 28/255,  green: 28/255,  blue: 31/255)
    static let tvdAccent     = Color(red: 255/255, green: 159/255, blue: 10/255)
    static let tvdDivider    = Color(red: 56/255,  green: 56/255,  blue: 61/255)
    static let tvdPrimary    = Color(red: 240/255, green: 240/255, blue: 247/255)
    static let tvdSecondary  = Color(red: 94/255,  green: 94/255,  blue: 102/255)
}

// MARK: - Shared Button Style

private struct TVDPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .font(.headline)
            .background(isEnabled ? Color.tvdAccent : Color.tvdDivider)
            .foregroundStyle(isEnabled ? Color.tvdBackground : Color.tvdSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

// MARK: - Shared Components

private struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack(alignment: .top) {
            Text(label).font(.subheadline).foregroundStyle(Color.tvdSecondary)
            Spacer()
            Text(value).font(.subheadline).foregroundStyle(Color.tvdPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}

private struct CardView<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(spacing: 0) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.tvdSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct CardDivider: View {
    var body: some View { Divider().background(Color.tvdDivider) }
}

/// Live countdown for server-provided `expires_at` on the verification challenge.
private struct ChallengeExpiryCountdown: View {
    let expiresAt: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let remaining = expiresAt.timeIntervalSince(context.date)
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "timer")
                    .foregroundStyle(Color.tvdAccent)
                if remaining > 0 {
                    Text(L10n.tr("readiness.countdown_label"))
                        .font(.subheadline)
                        .foregroundStyle(Color.tvdSecondary)
                    Text(Self.formatRemaining(remaining))
                        .font(.subheadline.weight(.semibold).monospacedDigit())
                        .foregroundStyle(Color.tvdPrimary)
                } else {
                    Text(L10n.tr("readiness.challenge_expired"))
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.tvdSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private static func formatRemaining(_ ti: TimeInterval) -> String {
        let total = max(0, Int(ti.rounded(.down)))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Learn More Sheet

private struct LearnMoreSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(L10n.tr("learn_more.body"))
                        .font(.body).foregroundStyle(Color.tvdSecondary)

                    techSection(
                        title: L10n.tr("learn_more.section1.title"),
                        body: L10n.tr("learn_more.section1.body")
                    )
                    techSection(
                        title: L10n.tr("learn_more.section2.title"),
                        body: L10n.tr("learn_more.section2.body")
                    )
                    techSection(
                        title: L10n.tr("learn_more.section3.title"),
                        body: L10n.tr("learn_more.section3.body")
                    )
                }
                .padding(20)
            }
            .background(Color.tvdBackground.ignoresSafeArea())
            .navigationTitle(L10n.tr("learn_more.nav_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.tr("learn_more.done")) { dismiss() }
                        .foregroundStyle(Color.tvdAccent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func techSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline).foregroundStyle(Color.tvdPrimary)
            Text(body).font(.subheadline).foregroundStyle(Color.tvdSecondary)
        }
    }
}

// MARK: - Screen 1: Intro

struct IntroView: View {
    @Bindable var vm: ProofViewModel
    @State private var showLearnMore = false

    var body: some View {
        ZStack {
            Color.tvdBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(L10n.tr("intro.title"))
                        .font(.largeTitle).bold()
                        .foregroundStyle(Color.tvdPrimary)

                    Text(L10n.tr("intro.body"))
                        .font(.body).foregroundStyle(Color.tvdSecondary)

                    CardView {
                        InfoRow(label: L10n.tr("intro.verify_content"), value: L10n.tr("intro.badge_value"))
                        CardDivider()
                        InfoRow(label: L10n.tr("intro.verify_condition"), value: L10n.tr("intro.condition_value"))
                        CardDivider()
                        InfoRow(label: L10n.tr("intro.how_to_label"), value: L10n.tr("intro.how_to_value"))
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lock.shield").foregroundStyle(Color.tvdSecondary)
                        Text(L10n.tr("intro.privacy_note"))
                            .font(.footnote).foregroundStyle(Color.tvdSecondary)
                    }
                    .padding(16)
                    .background(Color.tvdSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(spacing: 12) {
                        Button(L10n.tr("intro.start")) { vm.flowStep = .readiness }
                            .buttonStyle(TVDPrimaryButtonStyle())

                        Button(L10n.tr("intro.learn_shared")) { showLearnMore = true }
                            .font(.subheadline)
                            .foregroundStyle(Color.tvdAccent)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showLearnMore) { LearnMoreSheet() }
    }
}

// MARK: - Screen 2: Readiness Check

private enum ReadinessStatus {
    case ready(String)
    case loading(String)
    case notReady(String)
}

private struct ReadinessRow: View {
    let label: String
    let status: ReadinessStatus

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(label).font(.subheadline).foregroundStyle(Color.tvdPrimary)
                statusLabel
            }
            Spacer()
            statusIcon
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    @ViewBuilder private var statusLabel: some View {
        switch status {
        case .ready(let s):   Text(s).font(.caption).foregroundStyle(.green)
        case .loading(let s): Text(s).font(.caption).foregroundStyle(Color.tvdSecondary)
        case .notReady(let s): Text(s).font(.caption).foregroundStyle(.red)
        }
    }

    @ViewBuilder private var statusIcon: some View {
        switch status {
        case .ready:
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case .loading:
            ProgressView().controlSize(.small).tint(Color.tvdAccent)
        case .notReady:
            Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
        }
    }
}

struct ReadinessView: View {
    @Bindable var vm: ProofViewModel
    @State private var isIdHidden = true
    @State private var showDownloadWarning = false

    private var ticketStatus: ReadinessStatus {
        switch vm.spTicketStatus {
        case .success: return .ready(L10n.tr("status.ready"))
        case .failure(let m): return .notReady(m)
        default: return .loading(L10n.tr("status.preparing"))
        }
    }

    private var circuitStatus: ReadinessStatus {
        if vm.circuitReady { return .ready(L10n.tr("status.ready")) }
        if vm.isDownloading {
            return .loading(
                String(format: L10n.tr("status.downloading"), Int(vm.downloadProgress * 100)))
        }
        return .loading(L10n.tr("status.preparing"))
    }

    private var allReady: Bool {
        vm.moicaAppInstalled && vm.spTicketStatus.isSuccess && vm.circuitReady && !vm.isChallengeExpired
    }

    /// Taiwan national ID: one uppercase letter followed by exactly 9 digits
    private var isValidIdNumber: Bool {
        let id = vm.idNum.trimmingCharacters(in: .whitespaces)
        return id.count == 10 &&
               id.first?.isUppercase == true &&
               id.dropFirst().allSatisfy(\.isNumber)
    }

    var body: some View {
        ZStack {
            Color.tvdBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(L10n.tr("readiness.title"))
                        .font(.largeTitle).bold()
                        .foregroundStyle(Color.tvdPrimary)

                    Text(L10n.tr("readiness.subtitle"))
                        .font(.body).foregroundStyle(Color.tvdSecondary)

                    CardView {
                        ReadinessRow(
                            label: L10n.tr("readiness.moica_app"),
                            status: vm.moicaAppInstalled
                                ? .ready(L10n.tr("readiness.installed"))
                                : .notReady(L10n.tr("readiness.not_installed"))
                        )
                        CardDivider()
                        ReadinessRow(label: L10n.tr("readiness.local_verifier"), status: circuitStatus)
                        CardDivider()
                        HStack {
                            Text(L10n.tr("readiness.national_id"))
                                .font(.subheadline)
                                .foregroundStyle(Color.tvdSecondary)
                                .fixedSize()
                            Group {
                                if isIdHidden {
                                    SecureField(L10n.tr("readiness.id_placeholder"), text: $vm.idNum)
                                } else {
                                    TextField(L10n.tr("readiness.id_placeholder"), text: $vm.idNum)
                                }
                            }
                            .font(.subheadline)
                            .foregroundStyle(Color.tvdPrimary)
                            .tint(Color.tvdAccent)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.characters)
                            .submitLabel(.done)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: vm.idNum) { _, _ in
                                vm.resetIdentityCheckOnIdNumberEdit()
                            }
                            Button {
                                isIdHidden.toggle()
                            } label: {
                                Image(systemName: isIdHidden ? "eye.slash" : "eye")
                                    .foregroundStyle(Color.tvdSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        CardDivider()
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(L10n.tr("readiness.check_id"))
                                    .font(.subheadline).foregroundStyle(Color.tvdPrimary)
                                Group {
                                    switch vm.spTicketStatus {
                                    case .idle:
                                        if case .failure(let msg) = vm.tbsStatus {
                                            Text(msg).foregroundStyle(.red).lineLimit(2)
                                        } else if vm.idNum.isEmpty {
                                            Text(L10n.tr("readiness.id_hint_enter"))
                                                .foregroundStyle(Color.tvdSecondary)
                                        } else if !isValidIdNumber {
                                            Text(L10n.tr("readiness.id_hint_invalid"))
                                                .foregroundStyle(Color.tvdAccent)
                                        } else {
                                            Text(L10n.tr("status.preparing"))
                                                .foregroundStyle(Color.tvdSecondary)
                                        }
                                    case .running:
                                        Text(L10n.tr("status.preparing")).foregroundStyle(Color.tvdSecondary)
                                    case .success:
                                        Text(L10n.tr("status.ready")).foregroundStyle(.green)
                                    case .failure(let m):
                                        Text(m).foregroundStyle(.red).lineLimit(2)
                                    }
                                }
                                .font(.caption)
                            }
                            Spacer()
                            switch vm.spTicketStatus {
                            case .success:
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            case .running:
                                ProgressView().controlSize(.small).tint(Color.tvdAccent)
                            case .failure(let m) where m != L10n.tr("moica.PM_IDN_FT_ERR"):
                                Button {
                                    UIPasteboard.general.string = m
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                        .font(.title3).foregroundStyle(Color.tvdSecondary)
                                }
                                .buttonStyle(.plain)
                            default:
                                if vm.tbsStatus == .running || (isValidIdNumber && vm.circuitReady) {
                                    ProgressView().controlSize(.small).tint(Color.tvdAccent)
                                } else {
                                    Image(systemName: "clock")
                                        .font(.title3).foregroundStyle(Color.tvdSecondary)
                                }
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .animation(.default, value: vm.spTicketStatus)
                        .animation(.default, value: vm.tbsStatus)
                        CardDivider()
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(L10n.tr("readiness.sign_auth")).font(.subheadline).foregroundStyle(Color.tvdPrimary)
                                Text(L10n.tr("readiness.sign_auth_sub"))
                                    .font(.caption).foregroundStyle(Color.tvdSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption).foregroundStyle(Color.tvdSecondary)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                    }

                    VStack(spacing: 12) {
                        // Drive `disabled` off real time when the server sends `expires_at`, so the button
                        // turns off when the countdown hits zero without waiting for another `@Observable` change.
                        if vm.challengeExpiresAt != nil {
                            TimelineView(.periodic(from: .now, by: 1)) { _ in
                                Button(L10n.tr("readiness.go_moica")) { vm.openMOICA() }
                                    .buttonStyle(TVDPrimaryButtonStyle())
                                    .disabled(!allReady)
                            }
                        } else {
                            Button(L10n.tr("readiness.go_moica")) { vm.openMOICA() }
                                .buttonStyle(TVDPrimaryButtonStyle())
                                .disabled(!allReady)
                        }

                        Button(L10n.tr("readiness.back")) { vm.reset() }
                            .font(.subheadline).foregroundStyle(Color.tvdSecondary)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .padding(.bottom, 40)
            }
        }
        .task {
            if vm.circuitReady {
                guard isValidIdNumber else { return }
                requestChallenge()
            } else if !vm.isDownloading {
                showDownloadWarning = true
            }
        }
        .onChange(of: vm.circuitReady) { _, isReady in
            guard isReady, isValidIdNumber else { return }
            requestChallenge()
        }
        .onChange(of: isValidIdNumber) { _, isValid in
            guard isValid, vm.circuitReady else { return }
            requestChallenge()
        }
        .alert(L10n.tr("readiness.download_warning.title"), isPresented: $showDownloadWarning) {
            Button(L10n.tr("readiness.download_warning.confirm")) {
                Task { await vm.downloadCircuit() }
            }
            Button(L10n.tr("readiness.back"), role: .cancel) { vm.reset() }
        } message: {
            Text(L10n.tr("readiness.download_warning.message"))
        }
    }

    private func requestChallenge() {
        guard case .idle = vm.spTicketStatus else { return }
        Task {
            let canReuse: Bool = {
                guard case .success = vm.tbsStatus else { return false }
                if let end = vm.challengeExpiresAt { return Date() < end }
                return true
            }()
            if !canReuse { await vm.regenerateTBS() }
            if case .failure = vm.tbsStatus { return }
            await vm.computeSPTicket()
        }
    }
}

// MARK: - Screen 4: Return from MOICA

struct MOICAReturnedView: View {
    @Bindable var vm: ProofViewModel

    var body: some View {
        ZStack {
            Color.tvdBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.green)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)

                    Text(L10n.tr("returned.title"))
                        .font(.largeTitle).bold()
                        .foregroundStyle(Color.tvdPrimary)

                    Text(L10n.tr("returned.body"))
                        .font(.body).foregroundStyle(Color.tvdSecondary)

                    CardView {
                        InfoRow(label: L10n.tr("returned.verify_content"), value: L10n.tr("intro.badge_value"))
                        CardDivider()
                        InfoRow(
                            label: L10n.tr("returned.credential_type"), value: L10n.tr("returned.moica_name"))
                        CardDivider()
                        HStack {
                            Text(L10n.tr("returned.signing_status")).font(.subheadline).foregroundStyle(Color.tvdSecondary)
                            Spacer()
                            signingStatusView
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        CardDivider()
                        InfoRow(label: L10n.tr("returned.next_step"), value: L10n.tr("returned.next_value"))
                    }

                    VStack(spacing: 12) {
                        Button(L10n.tr("returned.continue")) {
                            Task { await vm.runLocalVerification() }
                        }
                        .buttonStyle(TVDPrimaryButtonStyle())
                        .disabled(!vm.athResultStatus.isSuccess)

                        Button(L10n.tr("readiness.back")) { vm.reset() }
                            .font(.subheadline).foregroundStyle(Color.tvdSecondary)
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 40)
            }
        }
    }

    @ViewBuilder private var signingStatusView: some View {
        switch vm.athResultStatus {
        case .success:
            Label(L10n.tr("signing.done"), systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                .font(.subheadline)
        case .running:
            HStack(spacing: 6) {
                ProgressView().controlSize(.small).tint(Color.tvdAccent)
                Text(L10n.tr("signing.checking")).font(.subheadline).foregroundStyle(Color.tvdSecondary)
            }
        case .failure:
            Label(L10n.tr("signing.incomplete"), systemImage: "xmark.circle.fill").foregroundStyle(.red)
                .font(.subheadline)
        case .idle:
            Text(L10n.tr("signing.waiting")).font(.subheadline).foregroundStyle(Color.tvdSecondary)
        }
    }
}

// MARK: - Chip Flow Layout

private struct ChipFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        layout(in: proposal.width ?? 0, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        for (subview, frame) in zip(subviews, layout(in: bounds.width, subviews: subviews).frames) {
            subview.place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                          proposal: ProposedViewSize(frame.size))
        }
    }

    private func layout(in width: CGFloat, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        var frames: [CGRect] = []
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for subview in subviews {
            let s = subview.sizeThatFits(.unspecified)
            if x + s.width > width, x > 0 { y += rowH + spacing; x = 0; rowH = 0 }
            frames.append(CGRect(origin: .init(x: x, y: y), size: s))
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
        return (CGSize(width: width, height: y + rowH), frames)
    }
}

// MARK: - Screens 5 & 6: Verification Progress

private enum ProgressItemState { case done, active, pending }

private struct ProgressRow: View {
    let label: String
    let state: ProgressItemState

    var body: some View {
        HStack(spacing: 14) {
            Group {
                switch state {
                case .done:
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                case .active:
                    ProgressView().controlSize(.small).tint(Color.tvdAccent)
                        .frame(width: 18, height: 18)
                case .pending:
                    Image(systemName: "circle").foregroundStyle(Color.tvdDivider)
                }
            }
            .frame(width: 22)

            Text(label)
                .font(.subheadline)
                .foregroundStyle(state == .pending ? Color.tvdSecondary : Color.tvdPrimary)
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 10)
    }
}

struct VerificationProgressView: View {
    @Bindable var vm: ProofViewModel
    @State private var showLearnMore = false

    /// When false, `regenerateTBS()` must run before `computeSPTicket()` (missing session or challenge expired).
    private var shouldReuseChallengeSession: Bool {
        guard case .success = vm.tbsStatus else { return false }
        if let end = vm.challengeExpiresAt { return Date() < end }
        return true
    }

    var body: some View {
        ZStack {
            Color.tvdBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if vm.flowStep == .submitting {
                        submittingHeader
                    } else {
                        verifyingHeader
                    }

                    CardView {
                        ProgressRow(label: L10n.tr("progress.step1"),  state: .done)
                        CardDivider()
                        ProgressRow(label: L10n.tr("progress.step2"), state: .done)
                        CardDivider()
                        ProgressRow(label: L10n.tr("progress.step3"),     state: .done)
                        CardDivider()
                        ProgressRow(label: L10n.tr("progress.step4"),     state: itemState(vm.generateInputStatus))
                        CardDivider()
                        ProgressRow(label: L10n.tr("progress.step5"), state: itemState(vm.proveStatus))
                        CardDivider()
                        ProgressRow(label: L10n.tr("progress.step6"),     state: itemState(vm.verifyStatus))
                    }

                    if vm.flowStep == .submitting || vm.proveStatus != .idle {
                        privacyCard
                        Button(L10n.tr("progress.learn_tech")) { showLearnMore = true }
                            .font(.subheadline).foregroundStyle(Color.tvdAccent)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showLearnMore) { LearnMoreSheet() }
    }

    private func itemState(_ status: ProofViewModel.StepStatus) -> ProgressItemState {
        switch status {
        case .success: return .done
        case .running: return .active
        default:       return .pending
        }
    }

    private var verifyingHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.tr("progress.verifying_title"))
                .font(.largeTitle).bold().foregroundStyle(Color.tvdPrimary)
            Text(L10n.tr("progress.verifying_body"))
                .font(.body).foregroundStyle(Color.tvdSecondary)
        }
    }

    private var submittingHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.tr("progress.submitting_title"))
                .font(.largeTitle).bold().foregroundStyle(Color.tvdPrimary)
            Text(L10n.tr("progress.submitting_body"))
                .font(.body).foregroundStyle(Color.tvdSecondary)
        }
    }

    private var privacyCard: some View {
        CardView {
            VStack(alignment: .leading, spacing: 10) {
                Text(L10n.tr("progress.privacy_title"))
                    .font(.headline).foregroundStyle(Color.tvdPrimary)
                Text(L10n.tr("progress.privacy_body"))
                    .font(.subheadline).foregroundStyle(Color.tvdSecondary)
                ChipFlowLayout(spacing: 8) {
                    privacyChip(L10n.tr("progress.chip1"), icon: "checkmark.circle.fill", highlighted: true)
                    privacyChip(L10n.tr("progress.chip2"), icon: "lock.fill", highlighted: true)
                    privacyChip(L10n.tr("progress.chip3"), icon: "iphone", highlighted: true)
                }
            }
            .padding(16)
        }
    }

    private func privacyChip(_ label: String, icon: String, highlighted: Bool = false) -> some View {
        Label(label, systemImage: icon)
            .font(highlighted ? .caption : .caption2)
            .fontWeight(highlighted ? .semibold : .regular)
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(highlighted ? Color.tvdAccent : Color.tvdDivider)
            .foregroundStyle(highlighted ? Color.tvdBackground : Color.tvdSecondary)
            .clipShape(Capsule())
    }
}

// MARK: - Success Screen

struct SuccessView: View {
    @Bindable var vm: ProofViewModel
    @State private var showTechInfo = false

    var body: some View {
        ZStack {
            Color.tvdBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color.tvdAccent)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)

                    Text(L10n.tr("success.title"))
                        .font(.largeTitle).bold().foregroundStyle(Color.tvdPrimary)

                    Text(L10n.tr("success.body"))
                        .font(.body).foregroundStyle(Color.tvdSecondary)

                    CardView {
                        HStack {
                            Text(L10n.tr("success.banner"))
                                .font(.subheadline).foregroundStyle(.green)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                    }

                    CardView {
                        InfoRow(label: L10n.tr("success.result_label"), value: L10n.tr("success.result_ok"))
                        CardDivider()
                        InfoRow(label: L10n.tr("success.badge_label"), value: L10n.tr("intro.badge_value"))
                        CardDivider()
                        InfoRow(
                            label: L10n.tr("success.credential_label"), value: L10n.tr("returned.moica_name"))
                        if let total = vm.totalVerificationSeconds {
                            CardDivider()
                            InfoRow(
                                label: L10n.tr("success.total_time_label"),
                                value: String(format: L10n.tr("success.total_time_fmt"), total))
                        }
                        if let proveDetail = vm.proveStatus.successDetail {
                            CardDivider()
                            InfoRow(label: L10n.tr("success.eligibility_label"), value: proveDetail)
                        }
                        if let ms = vm.verifyMilliseconds {
                            CardDivider()
                            InfoRow(label: L10n.tr("success.submit_label"), value: "\(ms) ms")
                        }
                    }

                    DisclosureGroup(
                        isExpanded: $showTechInfo,
                        content: {
                            VStack(alignment: .leading, spacing: 8) {
                                if case .success(let d) = vm.proveStatus {
                                    techRow(label: "Prove", value: d)
                                }
                                if case .success(let d) = vm.verifyStatus {
                                    techRow(label: "Verify", value: d)
                                }
                            }
                            .padding(.top, 8)
                        },
                        label: {
                            Text(L10n.tr("success.tech_info"))
                                .font(.subheadline).foregroundStyle(Color.tvdSecondary)
                        }
                    )
                    .tint(Color.tvdSecondary)

                    Button(L10n.tr("success.back_homepage")) { vm.reset() }
                        .buttonStyle(TVDPrimaryButtonStyle())
                        .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 40)
            }
        }
    }

    private func techRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.caption.monospaced()).foregroundStyle(Color.tvdSecondary)
            Spacer()
            Text(value).font(.caption.monospaced()).foregroundStyle(Color.tvdPrimary)
        }
    }
}

private extension ProofViewModel.StepStatus {
    var successDetail: String? {
        if case .success(let d) = self { return d }
        return nil
    }
}

// MARK: - Error Screen

struct VerificationErrorView: View {
    @Bindable var vm: ProofViewModel
    let message: String
    @State private var copied = false

    private var errorTitle: String {
        if message.contains("MOICA") || message.contains("mobilemoica") {
            return L10n.tr("error.moica_open_title")
        }
        if message.contains("cancel") || message.contains("取消") {
            return L10n.tr("error.moica_incomplete_title")
        }
        if message.contains("nullifier already registered") {
            return L10n.tr("error.already_registered_title")
        }
        if message.contains("challenge expired") {
            return L10n.tr("error.challenge_expired_title")
        }
        return L10n.tr("error.generic_problem_title")
    }

    private var explanation: String {
        if message.contains("MOICA") || message.contains("mobilemoica") {
            return L10n.tr("error.explain.moica_open")
        }
        if message.contains("cancel") || message.contains("取消") {
            return L10n.tr("error.explain.cancel")
        }
        if message.contains("nullifier already registered") {
            return L10n.tr("error.explain.already_registered")
        }
        if message.contains("challenge expired") {
            return L10n.tr("error.explain.challenge_expired")
        }
        return L10n.tr("error.explain.generic")
    }

    var body: some View {
        ZStack {
            Color.tvdBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)

                    Text(L10n.tr("error.screen_title"))
                        .font(.largeTitle).bold().foregroundStyle(Color.tvdPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    CardView {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(errorTitle)
                                .font(.headline).foregroundStyle(Color.tvdPrimary)
                            Text(explanation)
                                .font(.subheadline).foregroundStyle(Color.tvdSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16).padding(.vertical, 14)
                    }

                    DisclosureGroup(
                        content: {
                            Text(message)
                                .font(.caption.monospaced())
                                .foregroundStyle(Color.tvdSecondary)
                                .textSelection(.enabled)
                                .padding(.top, 6)
                        },
                        label: {
                            Text(L10n.tr("error.details"))
                                .font(.caption).foregroundStyle(Color.tvdSecondary)
                        }
                    )
                    .tint(Color.tvdSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 12) {
                        Button(L10n.tr("error.retry")) {
                            vm.flowStep = .readiness
                            vm.spTicketStatus = .idle
                            vm.tbsStatus = .idle
                            vm.proveStatus = .idle
                            vm.verifyStatus = .idle
                            vm.generateInputStatus = .idle
                        }
                        .buttonStyle(TVDPrimaryButtonStyle())

                        Button(copied ? L10n.tr("error.copied") : L10n.tr("error.copy")) {
                            UIPasteboard.general.string = message
                            copied = true
                        }
                        .font(.subheadline).foregroundStyle(Color.tvdAccent)

                        Button(L10n.tr("error.back_homepage")) { vm.reset() }
                            .font(.subheadline).foregroundStyle(Color.tvdSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Root Content View

struct ContentView: View {
    @Bindable var vm: ProofViewModel

    var body: some View {
        ZStack {
            Color.tvdBackground.ignoresSafeArea()
            Group {
                switch vm.flowStep {
                case .intro:
                    IntroView(vm: vm)
                case .readiness:
                    ReadinessView(vm: vm)
                case .returned:
                    MOICAReturnedView(vm: vm)
                case .verifying, .submitting:
                    VerificationProgressView(vm: vm)
                case .success:
                    SuccessView(vm: vm)
                case .failure(let msg):
                    VerificationErrorView(vm: vm, message: msg)
                }
            }
            .transition(.opacity)
        }
        .animation(.easeInOut(duration: 0.25), value: vm.flowStep)
        .preferredColorScheme(.dark)
        .task {
            try? vm.prepareResources()
        }
    }
}

#Preview {
    ContentView(vm: ProofViewModel())
}
