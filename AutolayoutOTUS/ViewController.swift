//
//  ViewController.swift
//  AutolayoutOTUS
//
//  Created by Dmitrii Pogonia on 18.12.2025.
//

/*
 
 Цель:
 научится верстать с помощью Autolayout.
 
 Описание/Пошаговая инструкция выполнения домашнего задания:
 Добавить 2 UILabel на экран с равными отступами горизонтально
 Задать у 1го приоритет растяжения выше, чем у второго (протестировать в последствии, что контент внутри лейблов так и работает)
 Добавить UIImageView с отступом от центра на 1/10 экрана вверх но не более чем на 10 pt удаленно от label снизу
 Реализовать возможность переворота экрана, при перевороте выстроить все три view (2 label и UIImageView) горизонтально равноудаленно друг от друга и по 20 pt от краев superview
 
 Критерии оценки:
 Наличие всех вьюшек на экране - 30 баллов.
 Реакция на поворот экрана - 30 баллов.
 Правильное перераспределение вью на экране - 40 баллов.
 
 */

import UIKit

class ViewController: UIViewController {
    
    // Констрейнты для двух типов ориентации экрана - тип NSLayoutConstraint
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    // ЛЕЙБЛЫ
    private func makeLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    lazy var labelOne: UILabel = {
        let label = makeLabel()
        label.text = "First label"
        label.backgroundColor = .systemRed
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    lazy var labelTwo: UILabel = {
        let label = makeLabel()
        label.text = "Second label"
        label.backgroundColor = .systemBlue
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    // КАРТИНКА
    lazy var image: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "star.fill"))
        image.backgroundColor = .systemYellow
        image.layer.cornerRadius = 8
        image.layer.masksToBounds = true
        image.tintColor = .systemGreen
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    // БАЗОВЫЕ ФУНКЦИИ ЖИЗНЕННОГО ЦИКЛА
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupViews()
        setupConstraints()
        activateConstraintsForCurrentOrientation()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.activateConstraintsForCurrentOrientation()
        })
    }
    
    // НАСТРОЙКА ВЬЮ
    private func setupViews() {
        view.addSubview(labelOne)
        view.addSubview(labelTwo)
        view.addSubview(image)
    }
    
    
    // УСТАНОВКА КОНСТРЕЙНТОЫ
    private func setupConstraints() {
        
        // Портрет
        portraitConstraints = [
            // Два label с равными отступами от краёв и равной шириной
            labelOne.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            labelTwo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            labelTwo.leadingAnchor.constraint(equalTo: labelOne.trailingAnchor, constant: 50),
            
            labelOne.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            labelTwo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            labelOne.widthAnchor.constraint(equalTo: labelTwo.widthAnchor),
            
            // Image по центру и на 1/10 экрана выше центра
            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            image.widthAnchor.constraint(equalToConstant: 40),
            image.heightAnchor.constraint(equalToConstant: 40),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -(view.bounds.height / 10)) // одна десятая от высоты вью контроллера
        ]
        
        // мягкое ограничение: не более чем на 10 pt выше labelOne - не удалось внести в основной массив, работает только через .append, иначе конфликтует с image.centerYAnchor.constraint
        let maxOffsetConstraint: NSLayoutConstraint = image.topAnchor.constraint(
            lessThanOrEqualTo: labelOne.bottomAnchor,
            constant: -10
        )
        maxOffsetConstraint.priority = .defaultHigh
        portraitConstraints.append(maxOffsetConstraint)
        
        // LANDSCAPE: три view горизонтально, равноудалённо, по 20 pt от краёв
        landscapeConstraints = [
            // Отступы 20 pt от краёв
            labelOne.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            labelTwo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Все по центру по вертикали
            labelOne.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            labelTwo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            // Размеры картинки
            image.widthAnchor.constraint(equalToConstant: 40),
            image.heightAnchor.constraint(equalToConstant: 40),
            
            // Равные промежутки между элементами
            image.leadingAnchor.constraint(equalTo: labelOne.trailingAnchor),
            labelTwo.leadingAnchor.constraint(equalTo: image.trailingAnchor),
            
            // Равная ширина лейблов
            labelOne.widthAnchor.constraint(equalTo: labelTwo.widthAnchor)
        ]
    }
    
    // ФУНКЦИЯ ДЛЯ ВЫбОРА КОНСТРЕЙНТОВ ПРИ СМЕНЕ ОРИЕНТАЦИИ
    
    private func activateConstraintsForCurrentOrientation() {
        NSLayoutConstraint.deactivate(portraitConstraints)
        NSLayoutConstraint.deactivate(landscapeConstraints)
        
        if view.bounds.width > view.bounds.height { // определяем что больше
            NSLayoutConstraint.activate(landscapeConstraints)   // landscape
        } else {
            NSLayoutConstraint.activate(portraitConstraints)    // portrait
        }
        
        view.layoutIfNeeded() // для плавности анимации при повороте, нейронка подсказала добавить
    }
    
    
}



// MARK: - Код до задания про поворот:

//import UIKit
//
//class ViewController: UIViewController {
//
//    func applyConstraints() {
//
//        NSLayoutConstraint.activate([
//            labelOne.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
//            labelTwo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
//            labelTwo.leadingAnchor.constraint(equalTo: labelOne.trailingAnchor, constant: 50),
//
//            labelOne.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            labelTwo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//
//            labelOne.widthAnchor.constraint(equalTo: labelTwo.widthAnchor),
//
//            image.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            image.widthAnchor.constraint(equalToConstant: 40),
//            image.heightAnchor.constraint(equalToConstant: 40),
//
//            image.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -(view.bounds.height / 10)) // поднимаем на 1/10 высоты
//        ])
//
//        // Ограничение: картинка не может быть выше, чем на 10 pt выше labelOne, внутрь не смог поместить, так как конфликтует с image.centerYAnchor.constraint
//        let maxOffsetConstraint = image.topAnchor.constraint(
//            lessThanOrEqualTo: labelOne.bottomAnchor,
//            constant: -10
//        )
//        maxOffsetConstraint.priority = .defaultHigh // чуть ниже, если нужно
//        maxOffsetConstraint.isActive = true
//    }
//
//    // решил сделать функцию создания дефолтного лейбла
//    private func makeLabel() -> UILabel {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.textColor = .white
//        label.layer.cornerRadius = 8
//        label.layer.masksToBounds = true
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }
//
//    lazy var labelOne: UILabel = {
//        let label = makeLabel()
//        label.text = "First label"
//        label.backgroundColor = .systemYellow
//        label.setContentHuggingPriority(.defaultHigh, for: .horizontal) // устанавливаю приоритеты
//        return label
//    }()
//
//    lazy var labelTwo: UILabel = {
//        let label = makeLabel()
//        label.text = "Second label"
//        label.backgroundColor = .systemBlue
//        label.setContentHuggingPriority(.defaultLow, for: .horizontal) // устанавливаю приоритеты
//        return label
//    }()
//
//    lazy var image: UIImageView = {
//        let image = UIImageView(image: UIImage(systemName: "star"))
//        image.tintColor = .systemGreen
//        image.contentMode = .scaleAspectFit
//        image.translatesAutoresizingMaskIntoConstraints = false
//        return image
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        setupViews()
//        applyConstraints()
//    }
//
//    func setupViews() {
//        view.addSubview(labelOne)
//        view.addSubview(labelTwo)
//        view.addSubview(image)
//    }
//}

