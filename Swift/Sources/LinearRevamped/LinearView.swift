import UIKit


final class LinearView: UIView {

	private let linearBattery: UILabel = {
		let label = UILabel()
		label.font = UIFont.boldSystemFont(ofSize: 8)
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let linearBar: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 2
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let fillBar: UIView = {
		let view = UIView()
		view.layer.cornerRadius = 2
		return view
	}()

	private var currentBattery = 0.0

	private let kFillBarLPMTintColor = UIColor.systemYellow
	private let kLinearBarLPMTintColor = UIColor.systemYellow.withAlphaComponent(0.5)
	private let kFillBarChargingTintColor = UIColor.systemGreen
	private let kLinearBarChargingTintColor = UIColor.systemGreen.withAlphaComponent(0.5)
	private let kFillBarLowBatteryTintColor = UIColor.systemRed
	private let kLinearBarLowBatteryTintColor = UIColor.systemRed.withAlphaComponent(0.5)

	init() {

		super.init(frame: .zero)

		UIDevice.current.isBatteryMonitoringEnabled = true

		NotificationCenter.default.removeObserver(self)
		NotificationCenter.default.addObserver(self, selector: #selector(updateViews), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(updateColors), name: Notification.Name("updateColors"), object: nil)

		setupViews()
		updateViews()

	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	private func setupViews() {

		linearBattery.text = String(format: "%.0f%%", currentBattery)

		guard !linearBattery.isDescendant(of: self),
			!linearBar.isDescendant(of: self),
			!fillBar.isDescendant(of: linearBar) else { return }

		addSubview(linearBattery)
		addSubview(linearBar)
		linearBar.addSubview(fillBar)

		linearBattery.topAnchor.constraint(equalTo: topAnchor).isActive = true
		linearBattery.centerXAnchor.constraint(equalTo: linearBar.centerXAnchor).isActive = true

		linearBar.topAnchor.constraint(equalTo: linearBattery.bottomAnchor, constant: 0.5).isActive = true
		linearBar.widthAnchor.constraint(equalToConstant: 26).isActive = true
		linearBar.heightAnchor.constraint(equalToConstant: 3.5).isActive = true

		fillBar.frame = CGRect(x: 0, y: 0, width: floor((currentBattery / 100) * 26), height: 3.5)

	}

	@objc private func updateViews() {

		currentBattery = Double(UIDevice.current.batteryLevel * 100)

		linearBattery.text = ""
		linearBattery.text = String(format: "%.0f%%", currentBattery)

		fillBar.frame = CGRect(x: 0, y: 0, width: floor((currentBattery / 100) * 26), height: 3.5)

	}

	@objc private func updateColors() {

		// not great but.. :bThisIsHowItIs:

		if currentBattery <= 20 && !BatteryState.isCharging && !BatteryState.isLPM {
			UIView.animate(withDuration: 0.5, delay: 0, options: .overrideInheritedCurve, animations: {
				self.fillBar.backgroundColor = self.kFillBarLowBatteryTintColor
				self.linearBar.backgroundColor = self.kLinearBarLowBatteryTintColor
			}, completion: nil)
		}

		if BatteryState.isCharging {
			UIView.animate(withDuration: 0.5, delay: 0, options: .overrideInheritedCurve, animations: {
				self.fillBar.backgroundColor = self.kFillBarChargingTintColor
				self.linearBar.backgroundColor = self.kLinearBarChargingTintColor
			}, completion: nil)
		}

		else if BatteryState.isLPM {
			UIView.animate(withDuration: 0.5, delay: 0, options: .overrideInheritedCurve, animations: {
				self.fillBar.backgroundColor = self.kFillBarLPMTintColor
				self.linearBar.backgroundColor = self.kLinearBarLPMTintColor
			}, completion: nil)
		}

		else if !BatteryState.isCharging && !BatteryState.isLPM && currentBattery > 20 {
			UIView.animate(withDuration: 0.5, delay: 0, options: .overrideInheritedCurve, animations: {
				self.fillBar.backgroundColor = .white
				self.linearBar.backgroundColor = .lightGray
			}, completion: nil)
		}

	}

}


enum BatteryState {

	static var isLPM = false
	static var isCharging = false

}
