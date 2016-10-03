//
//  ReverseGameViewController.swift
//  Magic Bricks
//
//  Created by Ty Victorson on 1/10/16.
//  Copyright © 2016 Ubix. All rights reserved.
//

import UIKit
import AVFoundation
import iAd

class ReverseGameViewController: UIViewController, AVAudioPlayerDelegate, UICollisionBehaviorDelegate {
    
    @IBOutlet weak var waveLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dificultyLevel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    var backgroundMusic = AVAudioPlayer()
    var collisionBehavior = UICollisionBehavior()
    var dynamicAnimator = UIDynamicAnimator()
    var wave = 0
    var face = UIView()
    var cube = UIView()
    var magicCubes : [UIView] = []
    var waveComplete = false
    var cubeSpeed = 10
    var allObjects : [UIView] = []
    var isWaveEnded = false
    var score = 0
    var numOfFallingBricks = 2
    var lives = 1
    
    // Timer Variables
    var time = 5
    var counting = false
    
    var highScore = Int()
    var removeAds = false
    var unlockEasyMode = false
    var activateX2 = false
    var x2 = false
    var activateEasyMode = false
    var activateHardMode = false
    var selectButtonColor = UIColor.black
    var secondSelectButton = UIColor.black
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add a red paddle object to the view
        face = UIView(frame: CGRect(x: view.center.x, y: view.center.y * 1.7
            , width: 40, height: 40))
        face.backgroundColor = UIColor.yellow
        face.layer.cornerRadius = 20
        face.clipsToBounds = true
        view.addSubview(face)
        
        dynamicAnimator = UIDynamicAnimator(referenceView: view)
        
        // create dynamic behavior for the cubes
        let brickDynamicBehavior = UIDynamicItemBehavior(items: magicCubes)
        brickDynamicBehavior.density = 10000
        brickDynamicBehavior.resistance = 100
        brickDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(brickDynamicBehavior)
        
        // create dynamic behavior for the ball
        let ballDynamicBehavior = UIDynamicItemBehavior(items: [face])
        ballDynamicBehavior.friction = 1000000000
        ballDynamicBehavior.resistance = 1000000000
        ballDynamicBehavior.elasticity = 1.0
        ballDynamicBehavior.allowsRotation = false
        dynamicAnimator.addBehavior(ballDynamicBehavior)
        allObjects.append(face)
        
        //creat collision behaviors so ball can bounce off other objects
        collisionBehavior = UICollisionBehavior(items: allObjects)
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true
        collisionBehavior.collisionMode = .everything
        collisionBehavior.collisionDelegate = self
        dynamicAnimator.addBehavior(collisionBehavior)
        
        if isWaveEnded == true {
            waveIncrement()
            isWaveEnded = false
        }
        
        // timer
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ReverseGameViewController.update), userInfo: nil, repeats: true)
        
        // infinently loop the background music
        backgroundMusic = self.setupAudioPlayerWithFile("MagicBricks - InGameTheme", type:"mp3")
        backgroundMusic.play()
        backgroundMusic.numberOfLoops = -1
        
        // wave settup
        waveLabel.text = "Wave \(wave)"
        
        // insantiate cubes
        spawnMoreBlocks(numOfFallingBricks)
        
        // fading label
        if waveComplete == true {
            counting = true
            waveLabel.isHidden = false
            time = 5
        }
    }
    
    // updates counter
    func update() {
        time -= 1
        if time == 0 {
            waveLabel.isHidden = true
            counting = false
        }
    }
    
    // Sound setup
    func setupAudioPlayerWithFile(_ file:NSString, type:NSString) -> AVAudioPlayer  {
        //1
        let path = Bundle.main.path(forResource: file as String, ofType:type as String)
        let url = URL(fileURLWithPath: path!)
        
        //2
        var audioPlayer:AVAudioPlayer?
        
        // 3
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
        } catch {
            print("Player not available")
        }
        
        //4
        return audioPlayer!
    }
    
    @IBAction func pauseButton(_ sender: UIButton) {
        startAlertActions()
    }
    
    // check for all blocks hidden
    func addBlock(_ x: Int, y: Int, color: UIColor) {
        let block = UIView(frame: CGRect(x: (CGFloat)(x), y: (CGFloat)(y), width: 20, height: 30))
        block.backgroundColor = color
        view.addSubview(block)
        magicCubes.append(block)
        allObjects.append(block)
        collisionBehavior.addItem(block)
    }
    
    func instantiateCubes() {
        // Set up bricks
        let width = (Int)(view.bounds.size.width - 41)
        let xOffset = ((Int)(view.bounds.size.width) % 42) / 2
        for var x = xOffset; x < width; x += 42 {addBlock(x, y:  0, color: UIColor.yellow)}
        pushCubes()
    }
    
    // updates wave
    func waveIncrement() {
        
        waveLabel.isHidden = false
        wave += 1
        waveLabel.text = "Wave \(wave)"
        numOfFallingBricks += 1
        
        dificultyLevel.backgroundColor = UIColor.green
        if wave <= 2 && wave < 5 {
            dificultyLevel.backgroundColor = UIColor.green
        }
        else if wave <= 5 && wave < 10{
            dificultyLevel.backgroundColor = UIColor.yellow
        }
        else if wave <= 10 && wave < 20{
            dificultyLevel.backgroundColor = UIColor.orange
        }
        else if wave >= 20 {
            dificultyLevel.backgroundColor = UIColor.red
        }
        
    }
    
    // collision behavior deligate method (with boundary)
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        var blocksHidden = 0
        for block in magicCubes {
            if item.isEqual(block) && p.y > face.center.y {
                block.isHidden = true
                collisionBehavior.removeItem(block)
                blocksHidden += 1
                if blocksHidden == magicCubes.count {
                    isWaveEnded = true
                }
                else if blocksHidden != magicCubes.count && lives == 0 {
                    waveLabel.isHidden = false
                    waveLabel.text = "Score: \(score)"
                    time = 5
                    counting = true
                    update()
                    if time == 0 {
                        counting = false
                        waveLabel.isHidden = true
                        startAlertActions()
                    }
                }
                
            }
            
            if (block.frame.intersects(face.frame)) {
                block.isHidden = true
                blocksHidden += 1
                collisionBehavior.removeItem(block)
                if blocksHidden == magicCubes.count {
                    isWaveEnded = true
                }
                else if blocksHidden != magicCubes.count && lives == 0 {
                    waveLabel.isHidden = false
                    waveLabel.text = "Score: \(score)"
                    time = 5
                    counting = true
                    update()
                    if time == 0 {
                        counting = false
                        waveLabel.isHidden = true
                        startAlertActions()
                    }
                }
            }
            
        }
    }
    
    // collision behavior delegate method (with another object)
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item1: UIDynamicItem, with item2: UIDynamicItem, at p: CGPoint) {
        var hiddenBlockCount = 0
        for block in magicCubes {
            
            if item1.isEqual(face) && item2.isEqual(block) {
                block.isHidden = true
                score += 1
                scoreLabel.text = "Cubes Eaten: \(score)"
                collisionBehavior.removeItem(block)
            }
            else if item1.isEqual(block) && item2.isEqual(face) {
                block.isHidden = true
                score += 1
                scoreLabel.text = "Cubes Eaten: \(score)"
                collisionBehavior.removeItem(block)
            }
            
            if block.isHidden == true {
                hiddenBlockCount += 1
            }
            
            // powerUp collision with paddle
            if (face.frame.intersects(block.frame)) {
                score += 1
                scoreLabel.text = "Cubes Eaten: \(score)"
                block.isHidden = true
            }
            
            // powerUp collision with paddle
            if (block.frame.intersects(face.frame)) {
                score += 1
                scoreLabel.text = "Cubes Eaten: \(score)"
                block.isHidden = true
            }
            
            
        }
        
        // moves to next wave
        if hiddenBlockCount == magicCubes.count {
            isWaveEnded = true
            spawnMoreBlocks(numOfFallingBricks)
        }
    }
    
    @IBAction func moveFaceGesture(_ sender: UIPanGestureRecognizer) {
        let panGesture = sender.location(in: view)
        face.center = CGPoint(x: panGesture.x, y: face.center.y)
        dynamicAnimator.updateItem(usingCurrentState: face)
        if infoLabel.isHidden == false {
            infoLabel.isHidden = true
        }
    }
    
    func pushCubes() {
        // create push behavior to get the cubes moving
        let pushBehavior = UIPushBehavior(items: magicCubes, mode: .instantaneous)
        pushBehavior.pushDirection = CGVector(dx: 0, dy: 1)
        pushBehavior.magnitude = 0.08
        dynamicAnimator.addBehavior(pushBehavior)
    }
    
    func makeMoreCubes() {
        cube = UIView(frame: CGRect(x: view.center.x, y: view.center.y, width: 20, height: 30))
        cube.backgroundColor = UIColor.yellow
        view.addSubview(cube)
        magicCubes.append(cube)
        allObjects.append(cube)
        cube.isHidden = true
    }
    
    func spawnMoreBlocks(_ numOfBricks: Int) {
        var numOfBricks = numOfBricks
        while numOfBricks > 0 {
            instantiateCubes()
            numOfBricks -= 1
            if numOfBricks == 0 {
                isWaveEnded = true
                waveIncrement()
            }
        }
    }
    
    func startAlertActions() {
        let alert = UIAlertController(title: "Paused", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let resumeAction = UIAlertAction(title: "Resume", style: UIAlertActionStyle.default) { (action) -> Void in
            
        }
        
        alert.addAction(resumeAction)
        self.present(alert, animated: true, completion: nil)
        
        let quitAction = UIAlertAction(title: "Quit", style: UIAlertActionStyle.destructive) { (action) -> Void in
            if let resultController = self.storyboard?.instantiateViewController(withIdentifier: "StartVC") as? ViewController {
                self.present(resultController, animated: true, completion: nil)
                //self.performSegueWithIdentifier("StartVC", sender: nil)
            }
            self.backgroundMusic.stop()
            
        }
        
        alert.addAction(quitAction)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StartVC" {
            let svc = segue.destination as! ViewController
                svc.x2 = x2
                svc.removeAds = removeAds
                svc.activateX2 = activateX2
                svc.highScore = highScore
                svc.unlockEasyMode = unlockEasyMode
                svc.activateHardMode = activateHardMode
                svc.selectButtonColor = selectButtonColor
        }
    }
}
