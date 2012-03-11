package
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxParticle;
	import org.flixel.FlxRect;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.FlxTilemap;
	import org.flixel.FlxU;

	public class PlayState extends FlxState
	{
		public var mapData:Array;
		public var tileMap:FlxTilemap;	
		
		
		public var player:FlxSprite;
		
		public var block:FlxSprite = new FlxSprite();
	
		public var bullets:FlxGroup;
		
		public var enemies:FlxGroup;
		
		public var bulletsArray:Array;
		
		public var bossLife:int;
		
		//OBJECTIVE IS TO DESTORY THE HUGE BLOCK ABOVE BY FINDING ENOUGH AMMO AROUND THE WORLD TO SAVE BLOCK PRINCESS
		
		public var blockBoss:FlxSprite;
		
		public var instructions:FlxText;
		
		public var blockCount:FlxText;
		public var blocksCollected:int;
		
		public var myBlockCount:FlxText;
		
		public var myCurrentBlockCount:int;
		
		public var particles:FlxGroup;
		
		public var blockPrincess:FlxSprite;
		
		public var gameOver:Boolean;
		public var savedPrincess:Boolean;
		
		override public function create():void
		{
			bossLife = 30;
			
			gameOver = false;
			savedPrincess = false;
			
			blocksCollected = 0;
			
			bulletsArray = new Array();
			
			myCurrentBlockCount = 50;
			bullets = new FlxGroup();
			enemies = new FlxGroup();
			particles = new FlxGroup();
			
			add(bullets);
			add(enemies);
			add(particles);
			
			blockCount = new FlxText( 0, 0,  300, "Blocks collected: 0" );
			blockCount.size = 20;
			blockCount.alignment = "left";
			add( blockCount );
			
			myBlockCount = new FlxText( 420, 0,  200, "My Blocks: 50" );
			myBlockCount.size = 20;
			add( myBlockCount );
			
			FlxG.bgColor = 0xffaa1111;
			
			
			blockBoss = new FlxSprite();
			blockBoss.makeGraphic( 200, 200, 0xFF000000);
			blockBoss.x = FlxG.stage.stageWidth / 2 - 100;
			blockBoss.y = FlxG.stage.stageHeight / 2 - 500;
			
			blockBoss.immovable = true;

			
			add( blockBoss );
			

			player = new FlxSprite();
			player.makeGraphic( 30, 30 );
			player.x = FlxG.stage.stageWidth / 2;
			player.y = FlxG.stage.stageHeight / 2 - 20;
			
			player.maxVelocity.x = 80;
			player.maxVelocity.y = 80;
			
			
			FlxG.camera.follow( player );
			
			add( player );
			
			instructions =  new FlxText( 0, 50, 600, "EXPLORE WORLD FOR BLOCKS TO DEFEAT BOSS SQUARE ABOVE AND SAVE PRINCESS! TOUCHING BLACK ENEMY WILL KILL YOU!!!" ); 
			instructions.size = 20;
			instructions.alignment = "center";
			add( instructions );
			
			//spawning enemies
			
			for( var i:int = 0; i < 200; i++ )
			{
				addEnemy();
			}
			
			FlxG.worldBounds = new FlxRect( -1000, -1000, 10000, 10000 );
		}
		
		public function addBullet( facing:uint ):void
		{
			var bullet:FlxSprite = new FlxSprite();
			bullet.facing = facing;
			bullet.makeGraphic( 10, 10 );
			bullet.x = player.x;
			bullet.y = player.y;
			bullet.allowCollisions = FlxObject.ANY;
			
			add( bullet );
			bulletsArray.push( bullet );
			bullets.add( bullet );
		}
		
		public function addEnemy():void
		{
			var enemy:FlxSprite = new FlxSprite();
			enemy.makeGraphic( 30, 30, 0xff000000 );
			enemy.x = Math.random() * 400 * Math.random() * 50;
			enemy.y = player.y + Math.random() * 400 * Math.random() * 20;
			
			
			add( enemy )
			
			enemies.add( enemy );
		}
		
		override public function update():void
		{
			super.update();
			
			updateHud();
			
			if( savedPrincess || gameOver == true ) return;
			
			
			updatePlayer();

			updateBullets();
			
			
			
			FlxG.collide( player, blockBoss, function( me:FlxObject, boss:FlxObject ):void
			{
				player.kill();
				gameOver = true;
			});
			
			FlxG.collide( player, enemies, function( me:FlxObject, enemy:FlxObject ):void
			{
				player.kill();
				gameOver = true;
			});
			
			FlxG.collide( player, particles, function( me:FlxObject, particle:FlxObject ):void
			{
				particle.kill();
				
				myCurrentBlockCount++;
				blocksCollected++;
			} );
			
			
			//checking bullet and enemy
			FlxG.collide( bullets, enemies, function( bullet:FlxObject, enemy:FlxObject ):void
			{
				bullet.kill();
				
				var enemyBlocksEmitter:FlxEmitter = new FlxEmitter( enemy.x, enemy.y, 20 );
				enemyBlocksEmitter.at( enemy );
				enemyBlocksEmitter.gravity = -10;
				enemyBlocksEmitter.lifespan = 5;
				enemyBlocksEmitter.maxParticleSpeed.x = 20;
				enemyBlocksEmitter.maxParticleSpeed.y = 20;
				enemyBlocksEmitter.particleDrag.x = 0;
				enemyBlocksEmitter.particleDrag.y = 0;
				
				
				enemyBlocksEmitter.bounce = 0.8;
				
				add( enemyBlocksEmitter );
				
				for( var iii:int = 0; iii < 20; iii++ )
				{
					var particle:FlxParticle = new FlxParticle();
					particle.makeGraphic( 5, 5, 0xff000000 );
					enemyBlocksEmitter.add( particle );
					particles.add( particle );
				}
				
				enemyBlocksEmitter.start();
				
				enemy.kill();
			} );
			
			//checking bullet with boss enemy
			FlxG.collide( bullets, blockBoss, function( bullet:FlxObject, enemy:FlxObject ):void
			{
				bullet.kill();
				
				bossLife--;
				
				if( bossLife <= 0 )
				{
					blockPrincess = new FlxSprite();
					blockPrincess.makeGraphic( 100, 100, 0xFFF52887 );
					blockPrincess.x = blockBoss.x;
					blockPrincess.y = blockBoss.y;
					add( blockPrincess );
					
					blockBoss.kill();
					player.kill();
					savedPrincess = true;
					
					instructions.text = "YOU SAVED THE BLOCK PRINCESS!";
				}
				
			} );
				
		}
		
		public function updateHud():void
		{
			if( gameOver != true )
			{
				blockCount.x = FlxG.camera.scroll.x;
				blockCount.y = FlxG.camera.scroll.y;
				blockCount.text = "Blocks Collected: " + blocksCollected.toString();
				blockCount.size = 20;
				
				myBlockCount.x = FlxG.camera.scroll.x + 420;
				myBlockCount.y = FlxG.camera.scroll.y;
				myBlockCount.text = "My Blocks: " + myCurrentBlockCount.toString();
				myBlockCount.size = 20;
			}
			else
			{
				blockCount.text = "GAME OVER, YOU WERE KILLED!";
				blockCount.x = FlxG.camera.scroll.x + 30;
				
				myBlockCount.visible = false;
			}
		}
		
		public function updateBullets():void
		{
			for( var i:int = 0; i < bulletsArray.length; i++ )
			{
				switch( bulletsArray[i].facing )
				{
					case FlxObject.RIGHT: bulletsArray[i].velocity.x += 10; break;
					case FlxObject.LEFT: bulletsArray[i].velocity.x -= 10; break;
					case FlxObject.UP: bulletsArray[i].velocity.y -= 10; break;
					case FlxObject.DOWN: bulletsArray[i].velocity.y += 10; break;
				}
			}
		}
		
		
		
		public function updatePlayer():void
		{
			if( FlxG.keys.RIGHT )
			{
				player.velocity.x = player.maxVelocity.x;
				player.facing = FlxObject.RIGHT;
			}
			else if( FlxG.keys.LEFT )
			{
				player.velocity.x = -player.maxVelocity.x;
				player.facing = FlxObject.LEFT;
			}
			else if( FlxG.keys.UP )
			{
				player.velocity.y = -player.maxVelocity.y;
				player.facing = FlxObject.UP;
			}
			else if( FlxG.keys.DOWN )
			{
				player.velocity.y = player.maxVelocity.y;
				player.facing = FlxObject.DOWN;
			}
			else
			{
				player.velocity.x = 0;
				player.velocity.y = 0;
			}
			
			if( FlxG.keys.SPACE )
			{
				if( myCurrentBlockCount > 0 )
				{
					addBullet( player.facing );
					myCurrentBlockCount--;
				}
			}
			
		}
		
	}
}