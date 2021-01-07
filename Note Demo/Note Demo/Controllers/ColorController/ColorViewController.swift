//
//  ColorViewController.swift
//  Note Demo
//
//  Created by Debashish Das on 11/11/20.
//  Copyright © 2020 debashish. All rights reserved.
//

import UIKit

protocol ColorViewControllerDelegate: AnyObject {
    func controller(_ controller: UIViewController, didPick color: UIColor)
}

class ColorViewController: UIViewController {
    
    weak var delegate: ColorViewControllerDelegate!
    var color: UIColor = .white
    //MARK: - Outlets
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var colorView: UIView!
    
    //MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pick Color"
        setupSlider()
        setupView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate.controller(self, didPick: colorView.backgroundColor ?? .white)
    }
    //MARK: - Helper Method
    private func setupView() {
        let color = UIColor(red: CGFloat(redSlider.value)
            , green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: 1.0)
        colorView.backgroundColor = color
    }
    private func setupSlider() {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        redSlider.value = Float(r)
        greenSlider.value = Float(g)
        blueSlider.value = Float(b)
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        setupView()
    }
}
