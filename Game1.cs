using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;

using System.IO;

namespace GetSDF
{
    public class Game1 : Game
    {
        GraphicsDeviceManager _graphics;
        GraphicsManager gm;
        Texture2D tex;
        RenderTarget2D targ;
        public Game1()
        {
            _graphics = new GraphicsDeviceManager(this);
            Content.RootDirectory = "Content";
            IsMouseVisible = true;
            _graphics.PreferredBackBufferWidth = 3088/3;
            _graphics.PreferredBackBufferHeight = 208;
            _graphics.GraphicsProfile = GraphicsProfile.HiDef;
        }

        protected override void Initialize()
        {
            // TODO: Add your initialization logic here
            base.Initialize();
        }

        protected override void LoadContent()
        {
            gm = new GraphicsManager(this.GraphicsDevice);
            gm.effect = Content.Load<Effect>("effect");
            tex = Content.Load<Texture2D>("miasma");
            targ = new RenderTarget2D(GraphicsDevice, tex.Width, tex.Height);
        }

        protected override void Update(GameTime gameTime)
        {

            base.Update(gameTime);
        }
        bool call = false;
        protected override void Draw(GameTime gameTime)
        {
            if (!call)
            {
                GraphicsDevice.Clear(Color.Red);
                gm.begin(tex, Vector2.Zero, new Vector2(targ.Width, targ.Height));
                gm.Draw(new Vector2(0, 0), new Vector2(targ.Width, targ.Height), Color.White);
                gm.flush(targ);                           

                //try
                //{
                    Stream s = File.Create("targ.png");

                    targ.SaveAsPng(s, targ.Width, targ.Height);
                    s.Close();
                //}
                //catch(System.Exception e)
                //{

                //    throw;
                //}
                call = true;
            }
            GraphicsDevice.Clear(Color.Red);
            gm.begin(tex, Vector2.Zero, new Vector2(targ.Width, targ.Height));
            gm.Draw(new Vector2(0, 0), new Vector2(targ.Width, targ.Height), Color.White);
            gm.flush(null);
            base.Draw(gameTime);
        }
    }
}